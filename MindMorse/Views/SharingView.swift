//
//  SharingView.swift
//  MindMorse
//
//  Created by Sana Sreeraj on 22/02/25.
//

import SwiftUI

struct SharingView: View {
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var sessionManager = MorseSessionManager()
    @State private var messageToSend: String = ""
    @State private var isShowingDevices = false
    @State private var showingAlert = false
    @State private var searchText = ""
    @State private var isTyping = false
    
    private var filteredMessages: [MessageViewModel] {
        let messages = sessionManager.messageStore.messages
        guard !searchText.isEmpty else { return messages }
        return messages.filter { message in
            message.text.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Search Bar
            SearchBar(text: $searchText)
                .padding()
            
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(filteredMessages) { message in
                            MessageRow(message: message, onReaction: { reaction in
                                // Handle reaction
                                handleReaction(reaction, for: message)
                            })
                            .id(message.id)
                            .transition(.asymmetric(
                                insertion: .scale.combined(with: .slide),
                                removal: .opacity
                            ))
                        }
                        
                        // Typing Indicator
                        if isTyping {
                            TypingIndicator()
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
                    .padding()
                }
                .onChange(of: sessionManager.messageStore.messages.count) { _ in
                    withAnimation {
                        proxy.scrollTo(sessionManager.messageStore.messages.last?.id)
                    }
                }
            }
            
            // Message Input
            MessageInputBar(
                text: $messageToSend,
                isTyping: $isTyping,
                onSend: {
                    sessionManager.send(message: messageToSend)
                    messageToSend = ""
                }
            )
        }
        .standardBackground()
        .navigationBarItems(
            trailing: HStack {
                Button(action: { isShowingDevices = true }) {
                    Image(systemName: "person.2.fill")
                        .foregroundColor(Theme.primary)
                }
                Button(action: { showingAlert = true }) {
                    Image(systemName: "info.circle")
                        .foregroundColor(Theme.primary)
                }
            }
        )
        .sheet(isPresented: $isShowingDevices) {
            DeviceListView(sessionManager: sessionManager)
        }
        .alert("About Sharing", isPresented: $showingAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Share Morse code messages with nearby devices using Multipeer Connectivity.")
        }
    }
    
    private func handleReaction(_ reaction: String, for message: MessageViewModel) {
        // Implement reaction handling
        print("Reacted with \(reaction) to message: \(message.id)")
        
        // You could send this reaction through the session manager
        // sessionManager.sendReaction(reaction, forMessage: message.id)
    }
}

// MARK: - Supporting Views
struct MessageRow: View {
    let message: MessageViewModel
    let onReaction: (String) -> Void
    @State private var showReactions = false
    
    var body: some View {
        HStack {
            if message.isSent {
                Spacer()
            }
            
            VStack(alignment: message.isSent ? .trailing : .leading) {
                // Message Bubble
                Text(message.text)
                    .padding()
                    .background(message.isSent ? Theme.primary : Color(.systemGray6))
                    .foregroundColor(message.isSent ? .white : .primary)
                    .cornerRadius(16)
                    .contextMenu {
                        Button(action: { showReactions = true }) {
                            Label("React", systemImage: "face.smiling")
                        }
                    }
                
                // Timestamp and Status
                HStack(spacing: 4) {
                    Text(message.timestamp, style: .time)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    if message.isSent {
                        Image(systemName: message.isRead ? "checkmark.circle.fill" : "checkmark.circle")
                            .foregroundColor(message.isRead ? .blue : .secondary)
                            .font(.caption2)
                    }
                }
            }
            
            if !message.isSent {
                Spacer()
            }
        }
        .sheet(isPresented: $showReactions) {
            ReactionPicker(onReaction: onReaction)
        }
    }
}

struct TypingIndicator: View {
    @State private var animationOffset: CGFloat = 0
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(Color.secondary)
                    .frame(width: 8, height: 8)
                    .offset(y: animationOffset)
                    .animation(
                        Animation
                            .easeInOut(duration: 0.6)
                            .repeatForever()
                            .delay(0.2 * Double(index)),
                        value: animationOffset
                    )
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(20)
        .onAppear {
            animationOffset = -5
        }
    }
}

struct MessageInputBar: View {
    @Binding var text: String
    @Binding var isTyping: Bool
    let onSend: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()
            HStack(spacing: 12) {
                TextField("Message", text: $text)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .onChange(of: text) { newValue in
                        isTyping = !newValue.isEmpty
                    }
                
                Button(action: onSend) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title2)
                        .foregroundColor(text.isEmpty ? .secondary : Theme.primary)
                }
                .disabled(text.isEmpty)
            }
            .padding()
        }
        .background(.thinMaterial)
    }
}

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Search messages", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}

struct ReactionPicker: View {
    let onReaction: (String) -> Void
    let reactions = ["👍", "❤️", "😂", "😮", "😢", "👏"]
    
    var body: some View {
        VStack {
            Text("React to message")
                .font(.headline)
                .padding()
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 60))]) {
                ForEach(reactions, id: \.self) { reaction in
                    Button(action: { onReaction(reaction) }) {
                        Text(reaction)
                            .font(.title)
                    }
                }
            }
            .padding()
        }
        .presentationDetents([.height(200)])
    }
}

struct DeviceListView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var sessionManager: MorseSessionManager
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    ForEach(sessionManager.nearbyDevices, id: \.self) { device in
                        Button(action: { sessionManager.connect(to: device) }) {
                            HStack {
                                Text(device.displayName)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                } header: {
                    Text("NEARBY DEVICES")
                } footer: {
                    if sessionManager.nearbyDevices.isEmpty {
                        Text("No devices found nearby. Make sure other devices have the app open and are within range.")
                    }
                }
            }
            .navigationTitle("Connect")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
