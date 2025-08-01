//
//  NFCView.swift
//  MindMorse
//
//  Created by Sana Sreeraj on 22/02/25.
//

import SwiftUI

struct NFCView: View {
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var nfcManager = NFCManager()
    @State private var showingScanAnimation = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: Theme.Layout.spacing) {
                // NFC Status Card
                Theme.Layout.card {
                    VStack(spacing: 16) {
                        Image(systemName: "radiowaves.right")
                            .font(.system(size: 48))
                            .foregroundColor(Theme.primary)
                            .rotationEffect(.degrees(showingScanAnimation ? 30 : -30))
                            .animation(
                                .easeInOut(duration: 1).repeatForever(autoreverses: true),
                                value: showingScanAnimation
                            )
                        
                        Theme.Typography.heading("NFC Scanner")
                        
                        Theme.Typography.caption("Scan NFC tags to read Morse code messages")
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                }
                
                // Scanned Content
                Theme.Layout.card {
                    VStack(alignment: .leading, spacing: 12) {
                        Theme.Typography.caption("SCANNED MESSAGE")
                        
                        if nfcManager.scannedMessage.isEmpty {
                            HStack {
                                Image(systemName: "doc.text")
                                Text("No message scanned yet")
                            }
                            .foregroundColor(.secondary)
                        } else {
                            Text(nfcManager.scannedMessage)
                                .font(.body)
                        }
                    }
                }
                
                Spacer()
                
                // Scan Button
                Button(action: {
                    nfcManager.beginScanning()
                    withAnimation {
                        showingScanAnimation = true
                    }
                }) {
                    Label("Scan NFC Tag", systemImage: "wave.3.right")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Theme.primary)
                        .foregroundColor(.white)
                        .cornerRadius(Theme.Layout.cornerRadius)
                }
            }
            .padding()
        }
        .background(
            Group {
                if colorScheme == .dark {
                    Theme.Gradients.darkBackground
                } else {
                    Theme.Gradients.background
                }
            }
            .ignoresSafeArea()
        )
        .onAppear { showingScanAnimation = true }
        .onDisappear { showingScanAnimation = false }
    }
}
