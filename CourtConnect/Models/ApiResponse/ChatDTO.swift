//
//  ChatDTO.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 22.01.25.
//
import Foundation 
 
class ChatDTO: Codable {
    var id: UUID
    var senderId: String
    var recipientId: String
    var message: String
    var createdAt: Date
    var readedAt: Date?
    
    init(id: UUID, senderId: String, recipientId: String, message: String, createdAt: Date, readedAt: Date? = nil) {
        self.id = id
        self.senderId = senderId
        self.recipientId = recipientId
        self.message = message
        self.createdAt = createdAt
        self.readedAt = readedAt
    }
    
    func toChat() -> Chat {
        do { 
            let decryptedMessage = try EncryptionHelper.toDecryptedString(text: message, senderId: id.uuidString)
             
            return Chat(id: id, senderId: senderId, recipientId: recipientId, message: decryptedMessage, createdAt: createdAt)
        } catch {
            return Chat(id: id, senderId: senderId, recipientId: recipientId, message: message, createdAt: createdAt)
        }
    }
} 
