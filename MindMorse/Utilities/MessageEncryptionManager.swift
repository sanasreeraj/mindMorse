import CryptoKit
import MultipeerConnectivity
import Foundation

class MessageEncryptionManager {
    private var privateKey: P256.KeyAgreement.PrivateKey
    private var signingKey: P256.Signing.PrivateKey
    private var sharedSecrets: [String: SymmetricKey] = [:]
    
    init() {
        privateKey = try! P256.KeyAgreement.PrivateKey()
        signingKey = try! P256.Signing.PrivateKey()
    }
    
    func encrypt(_ payload: MessagePayload) throws -> MessagePayload {
        guard payload.isEncrypted else { return payload }
        
        let messageData = try JSONEncoder().encode(payload)
        
        // Get or create symmetric key for encryption
        guard let symmetricKey = sharedSecrets[payload.senderName] else {
            throw CryptoError.missingSharedSecret
        }
        
        let sealedBox = try AES.GCM.seal(messageData, using: symmetricKey)
        
        // Sign the message
        let signature = try signingKey.signature(for: messageData)
        
        var encryptedPayload = payload
        encryptedPayload.encryptionKey = sealedBox.combined
        encryptedPayload.signature = signature.rawRepresentation
        
        return encryptedPayload
    }
    
    func decrypt(_ payload: MessagePayload, from peerId: MCPeerID) throws -> MessagePayload {
        guard payload.isEncrypted,
              let encryptedData = payload.encryptionKey,
              let signatureData = payload.signature else {
            return payload
        }
        
        let sealedBox = try AES.GCM.SealedBox(combined: encryptedData)
        guard let symmetricKey = sharedSecrets[peerId.displayName] else {
            throw CryptoError.missingSharedSecret
        }
        
        let decryptedData = try AES.GCM.open(sealedBox, using: symmetricKey)
        
        // Verify signature
        let signature = try P256.Signing.ECDSASignature(rawRepresentation: signatureData)
        let isValid = try signingKey.publicKey.isValidSignature(signature, for: decryptedData)
        
        guard isValid else {
            throw CryptoError.signatureVerificationFailed
        }
        
        return try JSONDecoder().decode(MessagePayload.self, from: decryptedData)
    }
    
    func getPublicKeyData() throws -> Data {
        return try privateKey.publicKey.rawRepresentation
    }
    
    func establishSharedSecret(with peer: MCPeerID, publicKeyData: Data) throws {
        guard let peerPublicKey = try? P256.KeyAgreement.PublicKey(rawRepresentation: publicKeyData) else {
            throw CryptoError.invalidPublicKey
        }
        
        // Generate shared secret
        let sharedSecret = try privateKey.sharedSecretFromKeyAgreement(with: peerPublicKey)
        
        // Derive symmetric key
        let symmetricKey = sharedSecret.hkdfDerivedSymmetricKey(
            using: SHA256.self,
            salt: "MindMorse".data(using: .utf8)!,
            sharedInfo: "MessageEncryption".data(using: .utf8)!,
            outputByteCount: 32
        )
        
        sharedSecrets[peer.displayName] = symmetricKey
    }
}

// MARK: - Errors
enum CryptoError: Error {
    case invalidPublicKey
    case missingSharedSecret
    case missingPublicKey
    case signatureVerificationFailed
}
