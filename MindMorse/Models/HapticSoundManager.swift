//
//  HapticSoundManager.swift
//  MindMorse
//
//  Created by Sana Sreeraj on 22/02/25.
//

import CoreHaptics
import AVFoundation

class HapticSoundManager {
    private var engine: CHHapticEngine?
    private var player: AVAudioPlayer?
    
    init() {
        do {
            engine = try CHHapticEngine()
            try engine?.start()
        } catch {
            print("Haptic engine error: \(error)")
        }
    }
    
    func playDot() {
        let dot = CHHapticEvent(eventType: .hapticTransient, parameters: [], relativeTime: 0)
        do {
            let pattern = try CHHapticPattern(events: [dot], parameters: [])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            print("Haptic error: \(error)")
        }
        
        if let path = Bundle.main.path(forResource: "dot", ofType: "mp3") {
            do {
                player = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
                player?.play()
            } catch {
                print("Sound error: \(error)")
            }
        }
    }
    
    func playDash() {
        let dash = CHHapticEvent(eventType: .hapticContinuous, parameters: [], relativeTime: 0, duration: 0.5)
        do {
            let pattern = try CHHapticPattern(events: [dash], parameters: [])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            print("Haptic error: \(error)")
        }
        
        if let path = Bundle.main.path(forResource: "dash", ofType: "mp3") {
            do {
                player = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
                player?.play()
            } catch {
                print("Sound error: \(error)")
            }
        }
    }
}

