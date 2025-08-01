//
//  ContentView.swift
//  MindMorse
//
//  Created by Sana Sreeraj on 21/02/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            NavigationView {
                MorseInputView()
                    .navigationTitle("Morse Input")
            }
            .tabItem {
                Label("Input", systemImage: "keyboard")
            }
            
            NavigationView {
                PracticeView()
                    .navigationTitle("Practice")
            }
            .tabItem {
                Label("Practice", systemImage: "brain.head.profile")
            }
            
            NavigationView {
                SharingView()
                    .navigationTitle("Share")
            }
            .tabItem {
                Label("Share", systemImage: "shareplay")
            }
            
            NavigationView {
                NFCView()
                    .navigationTitle("NFC")
            }
            .tabItem {
                Label("NFC", systemImage: "radiowaves.right")
            }
        }
        .tint(.blue)
    }
}
