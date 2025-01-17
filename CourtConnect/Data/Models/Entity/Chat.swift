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

@Model class Chat: Identifiable, Codable {
    var id: UUID
    var senderId: String // BBD9B046-4063-4C59-9A46-473A057FB2B4
    var recipientId: String
    var text: String
    var createdAt: Date
    var readedAt: Date? 
    
    enum CodingKeys: String, CodingKey {
        case id, senderId, recipientId, text, createdAt, readedAt
    }
    
    init(id: UUID = UUID(), senderId: String, recipientId: String, text: String, createdAt: Date = Date(), readedAt: Date?) {
        self.id = id
        self.text = text
        self.senderId = senderId
        self.recipientId = recipientId
        self.createdAt = createdAt
        self.readedAt = readedAt
    } 
    
    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.text = try container.decode(String.self, forKey: .text)
        self.recipientId = try container.decode(String.self, forKey: .recipientId)
        self.senderId = try container.decode(String.self, forKey: .senderId)
        let createdAtString = try container.decode(String.self, forKey: .createdAt)
        self.createdAt = DateUtil.convertDateStringToDate(string: createdAtString) ?? Date()
        
        let readedAtString = try container.decode(String.self, forKey: .readedAt)
        self.readedAt = DateUtil.convertDateStringToDate(string: readedAtString)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(senderId, forKey: .senderId)
        try container.encode(recipientId, forKey: .recipientId)
        try container.encode(text, forKey: .text)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(readedAt, forKey: .readedAt)
    }
}

extension Chat {
    /// Verschlüsselt
    func encryptMessage() -> Chat? {
        do {
            let entrypedText = try EncryptionHelper.encryptMessage(senderId: self.senderId, text: self.text)
            return Chat(id: id, senderId: senderId, recipientId: recipientId, text: entrypedText, readedAt: readedAt)
        } catch {
            return nil
        }
    }
    
    /// Entschlüssel
    func decryptMessage() -> Chat? {
        do {
            let decryptText = try EncryptionHelper.decryptMessage(text: text, senderId: senderId)
            return Chat(id: id, senderId: senderId, recipientId: recipientId, text: decryptText, readedAt: readedAt)
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
