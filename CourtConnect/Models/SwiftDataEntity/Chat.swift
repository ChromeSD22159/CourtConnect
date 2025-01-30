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
    var senderId: UUID
    var recipientId: UUID
    var message: String
    var createdAt: Date
    var updatedAt: Date
    var deletedAt: Date?
    var readedAt: Date?
     
    init(id: UUID = UUID(), senderId: UUID, recipientId: UUID, message: String, createdAt: Date, updatedAt: Date, deletedAt: Date? = nil, readedAt: Date? = nil) {
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
        return ChatDTO(id: id, senderId: senderId, recipientId: recipientId, message: message, createdAt: createdAt, updatedAt: updatedAt, deletedAt: deletedAt)
    }
}
