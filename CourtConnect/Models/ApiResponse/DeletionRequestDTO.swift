//
//  DeletionRequests.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 25.01.25.
//
import Foundation 

struct DeletionRequestDTO: Codable, SupabaseEntitiy {
    var id: UUID
    var userId: UUID
    var createdAt: Date
    var updatedAt: Date
    var deletedAt: Date?
    
    init(id: UUID = UUID(), userId: UUID, createdAt: Date, updatedAt: Date, deletedAt: Date? = nil) {
        self.id = id
        self.userId = userId
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
    }
}
