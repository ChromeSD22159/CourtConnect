//
//  Messages.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 17.01.25.
//
import Foundation
import SwiftUI
import SwiftData 
import Supabase

@Model
class Chat {
    @Attribute(.unique) var id: UUID
    var senderId: String
    var recipientId: String
    var message: String 
    var createdAt: Date
    var readedAt: Date?
    
    init(id: UUID = UUID(), senderId: String, recipientId: String, message: String, createdAt: Date, readedAt: Date? = nil) {
        self.id = id
        self.message = message
        self.senderId = senderId
        self.recipientId = recipientId
        self.createdAt = createdAt
        self.readedAt = readedAt
    }
    
    func toChat() -> ChatDTO? {
        do {
            let decryptedMessage = try EncryptionHelper.toEncryptedString(senderId: id.uuidString, text: message)
             
            return ChatDTO(id: self.id, senderId: self.senderId, recipientId: self.recipientId, message: decryptedMessage, createdAt: self.createdAt, readedAt: self.readedAt)
        } catch {
            return ChatDTO(id: self.id, senderId: self.senderId, recipientId: self.recipientId, message: self.message, createdAt: self.createdAt, readedAt: self.readedAt)
        }
    }
}
