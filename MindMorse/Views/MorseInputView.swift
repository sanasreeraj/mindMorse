//
//  MorseInputView.swift
//  MindMorse
//
//  Created by Sana Sreeraj on 22/02/25.
//

import SwiftUI

struct MorseInputView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var morseCode: String = ""
    @State private var translatedText: String = ""
    @State private var isShowingHelp = false
    private let hapticSoundManager = HapticSoundManager()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Input Display
                Card {
                    VStack(alignment: .leading, spacing: 8) {
                        SectionHeader(title: "MORSE CODE")
                        Text(morseCode.isEmpty ? "Tap to start..." : morseCode)
                            .font(.system(.title2, design: .monospaced))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundColor(morseCode.isEmpty ? .secondary : .primary)
                    }
                }
                
                // Translation Display
                Card {
                    VStack(alignment: .leading, spacing: 8) {
                        SectionHeader(title: "TRANSLATION")
                        Text(translatedText.isEmpty ? "Translation appears here" : translatedText)
                            .font(.title2)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundColor(translatedText.isEmpty ? .secondary : .primary)
                    }
                }
                
                Spacer(minLength: 32)
                
                // Input Controls
                VStack(spacing: 16) {
                    // Main Input Button
                    Button(action: {}) {
                        VStack(spacing: 8) {
                            Image(systemName: "hand.tap.fill")
                                .font(.system(size: 32))
                            Text("Tap for • (dot)")
                                .font(.headline)
                            Text("Hold for － (dash)")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 120)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .simultaneousGesture(
                        LongPressGesture(minimumDuration: 0.3)
                            .onEnded { _ in
                                morseCode += "-"
                                hapticSoundManager.playDash()
                                translatedText = MorseTranslator.translateMorse(morseCode)
                            }
                    )
                    .simultaneousGesture(
                        TapGesture()
                            .onEnded { _ in
                                morseCode += "."
                                hapticSoundManager.playDot()
                                translatedText = MorseTranslator.translateMorse(morseCode)
                            }
                    )
                    
                    HStack(spacing: 16) {
                        SecondaryButton("Space", icon: "space", color: .green) {
                            morseCode += " "
                            translatedText = MorseTranslator.translateMorse(morseCode)
                        }
                        
                        SecondaryButton("Delete", icon: "delete.left", color: .orange) {
                            if !morseCode.isEmpty {
                                morseCode.removeLast()
                                translatedText = MorseTranslator.translateMorse(morseCode)
                            }
                        }
                    }
                }
            }
            .standardPadding()
        }
        .standardBackground()
        .navigationBarItems(trailing: Button(action: { isShowingHelp = true }) {
            Image(systemName: "questionmark.circle")
        })
        .sheet(isPresented: $isShowingHelp) {
            MorseHelpView()
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Morse Code Input")
        .accessibilityHint("Tap for dot, hold for dash")
    }
}

struct MorseHelpView: View {
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("How to Use")) {
                    Text("• Tap the button for a dot (.)")
                    Text("• Hold the button for a dash (-)")
                    Text("• Use space between letters")
                    Text("• Use / between words")
                }
                
                Section(header: Text("Common Patterns")) {
                    Text("SOS = ... --- ...")
                    Text("Hello = .... . .-.. .-.. ---")
                }
            }
            .navigationTitle("Morse Code Help")
        }
    }
}
