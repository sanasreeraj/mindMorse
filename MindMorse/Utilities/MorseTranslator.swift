//
//  MorseTranslator.swift
//  MindMorse
//
//  Created by Sana Sreeraj on 22/02/25.
//

import Foundation

struct MorseTranslator {
    static let morseToLetter: [String: String] = [
        ".-": "A", "-...": "B", "-.-.": "C", "-..": "D", ".": "E",
        "..-.": "F", "--.": "G", "....": "H", "..": "I", ".---": "J",
        "-.-": "K", ".-..": "L", "--": "M", "-.": "N", "---": "O",
        ".--.": "P", "--.-": "Q", ".-.": "R", "...": "S", "-": "T",
        "..-": "U", "...-": "V", ".--": "W", "-..-": "X", "-.--": "Y",
        "--..": "Z", "/": " " // Add space for word separation
    ]
    
    static let letterToMorse: [String: String] = Dictionary(uniqueKeysWithValues: morseToLetter.map { ($1, $0) })
    
    // Translate Morse code to text (words and sentences)
    static func translateMorse(_ morse: String) -> String {
        let words = morse.components(separatedBy: " / ") // Split into words
        var translatedText = ""
        
        for word in words {
            let letters = word.components(separatedBy: " ") // Split into letters
            for code in letters {
                translatedText += morseToLetter[code] ?? "?"
            }
            translatedText += " " // Add space between words
        }
        return translatedText.trimmingCharacters(in: .whitespaces)
    }
    
    // Translate text to Morse code (words and sentences)
    static func translateText(_ text: String) -> String {
        var morseCode = ""
        let words = text.components(separatedBy: " ") // Split into words
        
        for word in words {
            for letter in word.uppercased() {
                morseCode += letterToMorse[String(letter)] ?? ""
                morseCode += " " // Add space between letters
            }
            morseCode += "/ " // Add slash between words
        }
        return morseCode.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
