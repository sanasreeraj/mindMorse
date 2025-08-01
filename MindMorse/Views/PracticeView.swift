//
//  PracticeView.swift
//  MindMorse
//
//  Created by Sana Sreeraj on 22/02/25.
//

import SwiftUI

struct PracticeView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var currentText: String = ""
    @State private var userInput: String = ""
    @State private var score: Int = 0
    @State private var timeRemaining: Int = 30
    @State private var isGameActive: Bool = false
    @State private var showGameOver = false
    @State private var showHint = false
    @State private var difficulty: DifficultyLevel = .medium
    @State private var highScores: [Int] = []
    @State private var showingScoreAnimation = false
    @State private var lastScoreIncrease = 0
    @State private var isTimeCritical = false
    
    // Animation states
    @State private var isTextChanging = false
    @State private var showSuccessOverlay = false
    @State private var rotationAngle: Double = 0
    
    let letters = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ")
    let words = ["HELLO", "WORLD", "SWIFT", "MORSE", "CODE"]
    let sentences = [
        "HELLO WORLD",
        "SWIFT IS AWESOME",
        "LEARN MORSE CODE",
        "PRACTICE MAKES PERFECT"
    ]
    
    var body: some View {
        ZStack {
            // Animated gradient background
            Theme.Gradients.background
                .hueRotation(.degrees(rotationAngle))
                .animation(.easeInOut(duration: 10).repeatForever(autoreverses: true), value: rotationAngle)
                .ignoresSafeArea()
                .onAppear {
                    rotationAngle = 360
                }
            
            ScrollView {
                VStack(spacing: 24) {
                    // Difficulty Picker with custom style
                    difficultyPicker
                    
                    // Score and Timer Card with animations
                    scoreAndTimerCard
                    
                    // Challenge Card with animations
                    challengeCard
                    
                    // Input Field with custom styling
                    inputField
                    
                    // Action Buttons with animations
                    actionButtons
                    
                    // High Scores with animations
                    if !highScores.isEmpty {
                        highScoresCard
                    }
                }
                .padding()
            }
            
            // Success overlay
            if showSuccessOverlay {
                successOverlayView
            }
            
            // Score increase animation
            if showingScoreAnimation {
                scoreIncreaseOverlay
            }
        }
        .onChange(of: timeRemaining) { newValue in
            isTimeCritical = newValue <= 10
        }
    }
    
    // MARK: - View Components
    
    private var difficultyPicker: some View {
        HStack(spacing: 20) {
            ForEach(DifficultyLevel.allCases, id: \.self) { level in
                Button(action: { 
                    withAnimation(.spring()) {
                        difficulty = level
                    }
                }) {
                    Text(level.rawValue)
                        .font(.headline)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(
                            difficulty == level ?
                            Theme.primary : Color.secondary.opacity(0.2)
                        )
                        .foregroundColor(difficulty == level ? .white : .primary)
                        .clipShape(Capsule())
                }
            }
        }
        .padding(.vertical)
    }
    
    private var scoreAndTimerCard: some View {
        Theme.Layout.card {
            HStack(spacing: 40) {
                // Score Display
                VStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .stroke(Color.yellow.opacity(0.3), lineWidth: 8)
                        Circle()
                            .trim(from: 0, to: CGFloat(score) / 100.0)
                            .stroke(Color.yellow, lineWidth: 8)
                            .rotationEffect(.degrees(-90))
                        
                        VStack {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                                .font(.title2)
                            Text("\(score)")
                                .font(.title)
                                .bold()
                        }
                    }
                    .frame(width: 100, height: 100)
                    
                    Text("SCORE")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Timer Display
                VStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .stroke(isTimeCritical ? Color.red.opacity(0.3) : Color.blue.opacity(0.3), lineWidth: 8)
                        Circle()
                            .trim(from: 0, to: CGFloat(timeRemaining) / 30.0)
                            .stroke(isTimeCritical ? Color.red : Color.blue, lineWidth: 8)
                            .rotationEffect(.degrees(-90))
                        
                        VStack {
                            Image(systemName: "timer")
                                .font(.title2)
                                .foregroundColor(isTimeCritical ? .red : .blue)
                            Text("\(timeRemaining)")
                                .font(.title)
                                .bold()
                                .foregroundColor(isTimeCritical ? .red : .primary)
                        }
                    }
                    .frame(width: 100, height: 100)
                    
                    Text("TIME")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
        }
    }
    
    private var challengeCard: some View {
        Theme.Layout.card {
            VStack(spacing: 16) {
                Text("TRANSLATE TO MORSE")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(currentText)
                    .font(.system(size: difficulty == .hard ? 32 : 40, weight: .bold, design: .monospaced))
                    .frame(minHeight: 80)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .opacity(isTextChanging ? 0 : 1)
                    .animation(.easeInOut(duration: 0.3), value: isTextChanging)
                
                if showHint {
                    Text(MorseTranslator.translateText(currentText))
                        .font(.system(.title2, design: .monospaced))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .padding()
        }
        .scaleEffect(isGameActive ? 1 : 0.95)
        .opacity(isGameActive ? 1 : 0.6)
        .animation(.spring(), value: isGameActive)
    }
    
    private var inputField: some View {
        Theme.Layout.card {
            VStack(alignment: .leading, spacing: 8) {
                Text("YOUR ANSWER")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                TextField("Type morse code here...", text: $userInput)
                    .font(.system(.title2, design: .monospaced))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .disabled(!isGameActive)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Theme.primary, lineWidth: 2)
                            .opacity(isGameActive ? 1 : 0)
                    )
            }
            .padding()
        }
    }
    
    private var actionButtons: some View {
        VStack(spacing: 16) {
            // Submit Button
            Button(action: checkAnswer) {
                Label("Submit Answer", systemImage: "checkmark.circle.fill")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isGameActive ? Theme.primary : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .shadow(radius: 3)
            }
            .disabled(!isGameActive)
            .scaleEffect(isGameActive ? 1 : 0.95)
            
            // Start/Restart Button
            Button(action: startGame) {
                Label(
                    isGameActive ? "Restart Game" : "Start Game",
                    systemImage: isGameActive ? "arrow.clockwise" : "play.fill"
                )
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Theme.success)
                .foregroundColor(.white)
                .cornerRadius(12)
                .shadow(radius: 3)
            }
        }
    }
    
    private var highScoresCard: some View {
        Theme.Layout.card {
            VStack(spacing: 12) {
                Text("HIGH SCORES")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                ForEach(highScores.sorted(by: >).prefix(5), id: \.self) { score in
                    Text("\(score)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Theme.primary)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding()
        }
    }
    
    private var successOverlayView: some View {
        Color.black.opacity(0.3)
            .ignoresSafeArea()
            .overlay(
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 100))
                    .foregroundColor(.green)
                    .transition(.scale.combined(with: .opacity))
            )
            .transition(.opacity)
    }
    
    private var scoreIncreaseOverlay: some View {
        Text("+\(lastScoreIncrease)")
            .font(.system(size: 40, weight: .bold))
            .foregroundColor(.green)
            .transition(.scale.combined(with: .opacity))
            .offset(y: -100)
    }
    
    // MARK: - Methods
    
    private func startGame() {
        withAnimation(.spring()) {
            score = 0
            timeRemaining = 30
            isGameActive = true
            generateNewText()
        }
    }
    
    private func generateNewText() {
        isTextChanging = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            switch difficulty {
            case .easy:
                currentText = String(letters.randomElement() ?? "A")
            case .medium:
                currentText = words.randomElement() ?? "HELLO"
            case .hard:
                currentText = sentences.randomElement() ?? "HELLO WORLD"
            }
            
            withAnimation(.spring()) {
                isTextChanging = false
            }
        }
    }
    
    private func checkAnswer() {
        if MorseTranslator.translateText(currentText) == userInput {
            // Success animation
            withAnimation {
                showSuccessOverlay = true
                lastScoreIncrease = difficulty.points
                showingScoreAnimation = true
                score += difficulty.points
            }
            
            // Reset animations
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation {
                    showSuccessOverlay = false
                    showingScoreAnimation = false
                }
            }
            
            HapticManager.shared.playSuccessHaptic()
        } else {
            HapticManager.shared.playErrorHaptic()
        }
        
        userInput = ""
        generateNewText()
    }
}

// MARK: - Supporting Types
enum DifficultyLevel: String, CaseIterable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"
    
    var points: Int {
        switch self {
        case .easy: return 1
        case .medium: return 3
        case .hard: return 5
        }
    }
}

// Haptic Feedback Manager
class HapticManager {
    static let shared = HapticManager()
    private let generator = UINotificationFeedbackGenerator()
    
    func playSuccessHaptic() {
        generator.notificationOccurred(.success)
    }
    
    func playErrorHaptic() {
        generator.notificationOccurred(.error)
    }
}
