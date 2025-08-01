//
//  NFCManager.swift
//  MindMorse
//
//  Created by Sana Sreeraj on 22/02/25.
//

import CoreNFC

class NFCManager: NSObject, ObservableObject, NFCNDEFReaderSessionDelegate {
    private var nfcSession: NFCNDEFReaderSession?
    @Published var scannedMessage: String = ""
    
    func beginScanning() {
        nfcSession = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: true)
        nfcSession?.begin()
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        if let payload = messages.first?.records.first {
            scannedMessage = String(data: payload.payload, encoding: .utf8) ?? "Invalid data"
        }
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        print("NFC session invalidated: \(error.localizedDescription)")
    }
}
