//
//  Messages.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 17.01.25.
//
import Foundation
import SwiftUI
import SwiftData
import RNCryptor
import Supabase

@Model
class Chat: Codable {
    @Attribute(.unique) var id: UUID
    var senderId: String
    var recipientId: String
    var message: String 
    var createdAt: Date
    var readedAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id, senderId, recipientId, readedAt, message, createdAt
    }
    
    init(id: UUID = UUID(), senderId: String, recipientId: String, message: String, createdAt: Date, readedAt: Date? = nil) {
        self.id = id
        self.message = message
        self.senderId = senderId
        self.recipientId = recipientId
        self.createdAt = createdAt
        self.readedAt = readedAt
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.message = try container.decode(String.self, forKey: .message)
        self.senderId = try container.decode(String.self, forKey: .senderId)
        self.recipientId = try container.decode(String.self, forKey: .recipientId)
        self.createdAt = try container.decode(Date.self, forKey: .createdAt)
        self.readedAt = try? container.decode(Date.self, forKey: .readedAt)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(senderId, forKey: .senderId)
        try container.encode(recipientId, forKey: .recipientId)
        try container.encode(message, forKey: .message)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(readedAt, forKey: .readedAt)
    }
}
/*
 
 extension Chat {
     /// Verschlüsselt
     func encryptMessage() -> Chat? {
         do {
             let entrypedText = try EncryptionHelper.encryptMessage(senderId: self.senderId, text: self.message)
             return Chat(id: id, senderId: senderId, recipientId: recipientId, message: entrypedText, createdAt: createdAt, readedAt: readedAt)
         } catch {
             return nil
         }
     }
     
     /// Entschlüssel
     func decryptMessage() -> Chat? {
         do {
             let decryptText = try EncryptionHelper.decryptMessage(text: message, senderId: senderId)
             return Chat(id: id, senderId: senderId, recipientId: recipientId, message: decryptText, createdAt: createdAt, readedAt: readedAt)
         } catch {
             return nil
         }
     }
 }

 struct EncryptionHelper {
     // Verschlüsselt
     static func encryptMessage(senderId: String, text: String) throws -> String {
         let messageData = text.data(using: .utf8)!
         let cipherData = RNCryptor.encrypt(data: messageData, withPassword: senderId)
         return cipherData.base64EncodedString()
     }
     
     // Entschlüssel
     static func decryptMessage(text: String, senderId: String) throws -> String {
         let encryptedData = Data.init(base64Encoded: text)!
         let decryptedData = try RNCryptor.decrypt(data: encryptedData, withPassword: senderId)
         let decryptedString = String(data: decryptedData, encoding: .utf8)!
         
         return decryptedString
     }
 }

 */
