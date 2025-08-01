//
//  MorseSessionManager.swift
//  MindMorse
//
//  Created by Sana Sreeraj on 22/02/25.
//

import MultipeerConnectivity
import SwiftUI
import Combine

class MorseSessionManager: NSObject, ObservableObject {
    // MARK: - Published Properties
    @Published var isConnected = false
    @Published var receivedMessages: [MessageViewModel] = []
    @Published var nearbyDevices: [MCPeerID] = []
    @Published var connectionState: ConnectionState = .disconnected
    @Published var isTyping = false
    
    // Make messageStore public but keep it read-only from outside
    public private(set) var messageStore: MessageStore
    
    // MARK: - Private Properties
    private let serviceType = "morse-share"
    private var session: MCSession
    private var advertiser: MCNearbyServiceAdvertiser
    private var browser: MCNearbyServiceBrowser
    private let peerID: MCPeerID
    private var cancellables = Set<AnyCancellable>()
    private let encryptionManager = MessageEncryptionManager()
    
    // MARK: - Connection States
    enum ConnectionState {
        case disconnected
        case searching
        case connecting
        case connected
        
        var description: String {
            switch self {
            case .disconnected: return "Disconnected"
            case .searching: return "Searching for devices..."
            case .connecting: return "Connecting..."
            case .connected: return "Connected"
            }
        }
    }
    
    // MARK: - Initialization
    override init() {
        peerID = MCPeerID(displayName: UIDevice.current.name)
        session = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
        advertiser = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: nil, serviceType: serviceType)
        browser = MCNearbyServiceBrowser(peer: peerID, serviceType: serviceType)
        messageStore = MessageStore(context: PersistenceController.shared.container.viewContext)
        
        super.init()
        
        session.delegate = self
        advertiser.delegate = self
        browser.delegate = self
        
        startServices()
        setupHaptics()
        
        // Subscribe to message store updates
        messageStore.$messages
            .receive(on: DispatchQueue.main)
            .sink { [weak self] messages in
                self?.receivedMessages = messages
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Public Methods
    func startServices() {
        advertiser.startAdvertisingPeer()
        browser.startBrowsingForPeers()
        connectionState = .searching
    }
    
    func stopServices() {
        advertiser.stopAdvertisingPeer()
        browser.stopBrowsingForPeers()
        session.disconnect()
        connectionState = .disconnected
    }
    
    func send(message: String) {
        guard !session.connectedPeers.isEmpty else { return }
        
        let payload = MessagePayload(
            id: UUID(),
            text: message,
            timestamp: Date(),
            senderName: peerID.displayName,
            messageType: .morse,
            isEncrypted: true
        )
        
        do {
            let encryptedPayload = try encryptionManager.encrypt(payload)
            let data = try JSONEncoder().encode(encryptedPayload)
            try session.send(data, toPeers: session.connectedPeers, with: .reliable)
            
            // Save to local store
            messageStore.saveMessage(payload, isSent: true)
            HapticManager.shared.playSuccessHaptic()
            
            // Send typing indicator
            sendTypingIndicator(false)
        } catch {
            print("Failed to send message: \(error)")
            HapticManager.shared.playErrorHaptic()
        }
    }
    
    func connect(to peer: MCPeerID) {
        browser.invitePeer(peer, to: session, withContext: nil, timeout: 30)
        connectionState = .connecting
    }
    
    func sendReadReceipt(for messageId: UUID) {
        let payload = MessagePayload(
            id: messageId,
            text: "",
            timestamp: Date(),
            senderName: peerID.displayName,
            messageType: .readReceipt,
            isEncrypted: false
        )
        
        do {
            let data = try JSONEncoder().encode(payload)
            try session.send(data, toPeers: session.connectedPeers, with: .reliable)
        } catch {
            print("Failed to send read receipt: \(error)")
        }
    }
    
    // MARK: - Private Methods
    private func setupHaptics() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
    }
    
    private func sendTypingIndicator(_ isTyping: Bool) {
        let payload = MessagePayload(
            id: UUID(),
            text: "",
            timestamp: Date(),
            senderName: peerID.displayName,
            messageType: .typing,
            isEncrypted: false
        )
        
        do {
            let data = try JSONEncoder().encode(payload)
            try session.send(data, toPeers: session.connectedPeers, with: .unreliable)
        } catch {
            print("Failed to send typing indicator: \(error)")
        }
    }
}

// MARK: - MCSessionDelegate
extension MorseSessionManager: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        DispatchQueue.main.async {
            switch state {
            case .connected:
                self.isConnected = true
                self.connectionState = .connected
                
                // Exchange encryption keys
                do {
                    let publicKeyData = try self.encryptionManager.getPublicKeyData()
                    try session.send(publicKeyData, toPeers: [peerID], with: .reliable)
                } catch {
                    print("Failed to exchange encryption keys: \(error)")
                }
                
                HapticManager.shared.playSuccessHaptic()
                
            case .connecting:
                self.connectionState = .connecting
                
            case .notConnected:
                self.isConnected = false
                self.connectionState = .disconnected
                HapticManager.shared.playErrorHaptic()
                
            @unknown default:
                break
            }
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        do {
            // Try to decode as MessagePayload first
            if let encryptedPayload = try? JSONDecoder().decode(MessagePayload.self, from: data) {
                let decryptedPayload = try encryptionManager.decrypt(encryptedPayload, from: peerID)
                
                switch decryptedPayload.messageType {
                case .morse, .text:
                    messageStore.saveMessage(decryptedPayload, isSent: false)
                    HapticManager.shared.playSuccessHaptic()
                    
                case .typing:
                    DispatchQueue.main.async {
                        withAnimation {
                            self.isTyping = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            withAnimation {
                                self.isTyping = false
                            }
                        }
                    }
                    
                case .readReceipt:
                    messageStore.markAsRead(decryptedPayload.id)
                }
            } else {
                // If not a message, assume it's a public key
                try encryptionManager.establishSharedSecret(with: peerID, publicKeyData: data)
            }
        } catch {
            print("Failed to process received data: \(error)")
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {}
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {}
}

// MARK: - MCNearbyServiceAdvertiserDelegate
extension MorseSessionManager: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        invitationHandler(true, session)
    }
}

// MARK: - MCNearbyServiceBrowserDelegate
extension MorseSessionManager: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String: String]?) {
        DispatchQueue.main.async {
            if !self.nearbyDevices.contains(peerID) {
                self.nearbyDevices.append(peerID)
            }
        }
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        DispatchQueue.main.async {
            self.nearbyDevices.removeAll { $0 == peerID }
        }
    }
}

// MARK: - Supporting Types
struct MessageData: Codable {
    let text: String
    let type: MessageType
    let timestamp: Date
    
    init(text: String, type: MessageType) {
        self.text = text
        self.type = type
        self.timestamp = Date()
    }
}

enum MessageType: String, Codable {
    case morse
    case text
}
