//
//  DeletionRequest.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 27.01.25.
//
import SwiftData
import Foundation

@Model
class DeletionRequest: ModelProtocol {
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
    
    func toDTO() -> DeletionRequestDTO {
        return DeletionRequestDTO(id: id, userId: userId, createdAt: createdAt, updatedAt: updatedAt, deletedAt: deletedAt)
    }
}
