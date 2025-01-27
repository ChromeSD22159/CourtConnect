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
class Chat: ModelProtocol {  
    @Attribute(.unique) var id: UUID
    var senderId: String
    var recipientId: String
    var message: String 
    var createdAt: Date
    var updatedAt: Date
    var deletedAt: Date?
    var readedAt: Date?
     
    init(id: UUID = UUID(), senderId: String, recipientId: String, message: String, createdAt: Date, updatedAt: Date, deletedAt: Date? = nil, readedAt: Date? = nil) {
        self.id = id
        self.senderId = senderId
        self.recipientId = recipientId
        self.message = message
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
        self.readedAt = readedAt
    }
    
    func toDTO() -> some DTOProtocol {
        do {
            let decryptedMessage = try EncryptionHelper.toEncryptedString(senderId: id.uuidString, text: message)
             
            return ChatDTO(id: self.id, senderId: self.senderId, recipientId: self.recipientId, message: decryptedMessage, readedAt: self.readedAt, createdAt: self.createdAt, updatedAt: updatedAt, deletedAt: deletedAt)
        } catch {
            return ChatDTO(id: self.id, senderId: self.senderId, recipientId: self.recipientId, message: self.message, readedAt: self.readedAt, createdAt: self.createdAt, updatedAt: updatedAt, deletedAt: deletedAt)
        }
    } 
}
