//
//  Persistence.swift
//  MindMorse
//
//  Created by Sana Sreeraj on 21/02/25.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        
        // Create example content
        let viewContext = controller.container.viewContext
        let newMessage = MorseMessage(context: viewContext)
        newMessage.id = UUID()
        newMessage.text = "Hello World"
        newMessage.timestamp = Date()
        newMessage.isSent = true
        newMessage.isRead = true
        newMessage.senderName = "Preview"
        newMessage.messageType = MessageKind.morse.rawValue
        
        try? viewContext.save()
        return controller
    }()

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "MindMorse")
        
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Error: \(error.localizedDescription)")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
}
