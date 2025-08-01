//
//  Message.swift
//  MindMorse
//
//  Created by Sana Sreeraj on 22/02/25.
//

import CoreData
import Foundation

// MARK: - Core Data Message Entity
@objc(MorseMessage)
public class MorseMessage: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var text: String
    @NSManaged public var timestamp: Date
    @NSManaged public var isSent: Bool
    @NSManaged public var isRead: Bool
    @NSManaged public var senderName: String
    @NSManaged public var messageType: String
}

extension MorseMessage {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<MorseMessage> {
        return NSFetchRequest<MorseMessage>(entityName: "MorseMessage")
    }
}

// MARK: - Message Types
enum MessageKind: String, Codable {
    case morse
    case text
    case typing
    case readReceipt
}

// MARK: - Message Transfer Model
struct MessagePayload: Codable {
    let id: UUID
    let text: String
    let timestamp: Date
    let senderName: String
    let messageType: MessageKind
    let isEncrypted: Bool
    
    var encryptionKey: Data?
    var signature: Data?
}

// MARK: - Message View Model
struct MessageViewModel: Identifiable {
    let id: UUID
    let text: String
    let timestamp: Date
    let isSent: Bool
    let isRead: Bool
    let senderName: String
    let messageType: MessageKind
    
    init(from entity: MorseMessage) {
        id = entity.id
        text = entity.text
        timestamp = entity.timestamp
        isSent = entity.isSent
        isRead = entity.isRead
        senderName = entity.senderName
        messageType = MessageKind(rawValue: entity.messageType) ?? .morse
    }
}
