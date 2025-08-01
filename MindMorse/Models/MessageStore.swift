import CoreData
import Combine
import SwiftUI

class MessageStore: ObservableObject {
    @Published private(set) var messages: [MessageViewModel] = []
    private let context: NSManagedObjectContext
    private var cancellables = Set<AnyCancellable>()
    
    init(context: NSManagedObjectContext) {
        self.context = context
        loadMessages()
    }
    
    func saveMessage(_ payload: MessagePayload, isSent: Bool) {
        context.perform { [weak self] in
            guard let self = self else { return }
            
            let message = MorseMessage(context: self.context)
            message.id = payload.id
            message.text = payload.text
            message.timestamp = payload.timestamp
            message.isSent = isSent
            message.isRead = isSent
            message.senderName = payload.senderName
            message.messageType = payload.messageType.rawValue
            
            do {
                try self.context.save()
                self.loadMessages()
            } catch {
                print("Failed to save message: \(error)")
            }
        }
    }
    
    func markAsRead(_ messageId: UUID) {
        context.perform { [weak self] in
            guard let self = self else { return }
            
            let request: NSFetchRequest<MorseMessage> = MorseMessage.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", messageId as CVarArg)
            
            do {
                let messages = try self.context.fetch(request)
                if let message = messages.first {
                    message.isRead = true
                    try self.context.save()
                    self.loadMessages()
                }
            } catch {
                print("Failed to mark message as read: \(error)")
            }
        }
    }
    
    private func loadMessages() {
        let request: NSFetchRequest<MorseMessage> = MorseMessage.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \MorseMessage.timestamp, ascending: true)]
        
        do {
            let entities = try context.fetch(request)
            DispatchQueue.main.async {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    self.messages = entities.map(MessageViewModel.init)
                }
            }
        } catch {
            print("Failed to load messages: \(error)")
        }
    }
}
