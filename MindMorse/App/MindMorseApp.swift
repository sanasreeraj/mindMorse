//
//  MindMorseApp.swift
//  MindMorse
//
//  Created by Sana Sreeraj on 21/02/25.
//

import SwiftUI

@main
struct MindMorseApp: App {
    let persistenceController = PersistenceController.shared
    @StateObject private var sessionManager = MorseSessionManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(sessionManager)
        }
    }
}
