//
//  SavedMessagesView.swift
//  MindMorse
//
//  Created by Sana Sreeraj on 22/02/25.
//

import SwiftUI
import CoreData
import UIKit

struct SavedMessagesView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var messageStore: MessageStore
    @State private var searchText = ""
    @State private var showingDeleteAlert = false
    @State private var messageToDelete: MessageViewModel?
    @State private var shareItem: ActivityItem?
    
    init(context: NSManagedObjectContext) {
        _messageStore = StateObject(wrappedValue: MessageStore(context: context))
    }
    
    private var filteredMessages: [MessageViewModel] {
        guard !searchText.isEmpty else { return messageStore.messages }
        return messageStore.messages.filter { message in
            message.text.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        List {
            ForEach(filteredMessages) { message in
                SavedMessageRow(message: message)
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            messageToDelete = message
                            showingDeleteAlert = true
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                        
                        Button {
                            shareMessage(message)
                        } label: {
                            Label("Share", systemImage: "square.and.arrow.up")
                        }
                        .tint(.blue)
                    }
            }
        }
        .searchable(text: $searchText, prompt: "Search messages")
        .navigationTitle("Saved Messages")
        .alert("Delete Message", isPresented: $showingDeleteAlert) {
            Button("Delete", role: .destructive) {
                if let message = messageToDelete {
                    deleteMessage(message)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to delete this message?")
        }
        .sheet(item: $shareItem) { item in
            ActivityView(activityItems: item.items)
        }
    }
    
    private func deleteMessage(_ message: MessageViewModel) {
        withAnimation {
            let fetchRequest: NSFetchRequest<MorseMessage> = MorseMessage.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", message.id as CVarArg)
            
            do {
                let messages = try viewContext.fetch(fetchRequest)
                if let messageToDelete = messages.first {
                    viewContext.delete(messageToDelete)
                    try viewContext.save()
                }
            } catch {
                print("Failed to delete message: \(error)")
            }
        }
    }
    
    private func shareMessage(_ message: MessageViewModel) {
        let messageText = """
        Message: \(message.text)
        Sent: \(message.timestamp.formatted())
        From: \(message.senderName)
        """
        
        shareItem = ActivityItem(items: [messageText])
    }
}

// MARK: - Supporting Views
struct SavedMessageRow: View {
    let message: MessageViewModel
    @State private var showReactions = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(message.text)
                    .font(.body)
                Spacer()
                if message.isRead {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.blue)
                }
            }
            
            HStack {
                Text(message.timestamp, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(message.timestamp, style: .time)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(message.senderName)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
        .contextMenu {
            Button(action: { showReactions = true }) {
                Label("React", systemImage: "face.smiling")
            }
        }
        .sheet(isPresented: $showReactions) {
            ReactionPicker { reaction in
                // Handle reaction
                print("Reacted with: \(reaction)")
                showReactions = false
            }
        }
    }
}

// MARK: - Activity Sharing
struct ActivityItem: Identifiable {
    let id = UUID()
    let items: [Any]
}

struct ActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ActivityView>) -> UIActivityViewController {
        UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: applicationActivities
        )
    }
    
    func updateUIViewController(
        _ uiViewController: UIActivityViewController,
        context: UIViewControllerRepresentableContext<ActivityView>
    ) {
        // Nothing to update
    }
}
