//
//  EncryptionHelper.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 22.01.25.
//
import RNCryptor
import Foundation

struct EncryptionHelper {
    // Funktion zum Verschlüsseln einer Nachricht
    // Diese Funktion nimmt die Sender-ID und den zu verschlüsselnden Text entgegen
    // und gibt den verschlüsselten Text als Base64-kodierten String zurück.
    static func toEncryptedString(senderId: UUID, text: String) throws -> String {
        let messageData = text.data(using: .utf8)!
        let cipherData = RNCryptor.encrypt(data: messageData, withPassword: senderId.uuidString)
        return cipherData.base64EncodedString()
    }
    
    // Funktion zum Entschlüsseln einer verschlüsselten Nachricht
    // Diese Funktion nimmt den verschlüsselten Text (Base64-kodiert) und die Sender-ID entgegen
    // und gibt den entschlüsselten Text zurück.
    static func toDecryptedString(text: String, senderId: UUID) throws -> String {
        guard !text.isEmpty else { return "" }
        guard let encryptedData = Data(base64Encoded: text) else { return "" }
        let decryptedData = try RNCryptor.decrypt(data: encryptedData, withPassword: senderId.uuidString)
        let decryptedString = String(data: decryptedData, encoding: .utf8)!
        
        return decryptedString
    }	
}
