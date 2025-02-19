//
//  UpdateHistory.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 29.01.25.
//
import SwiftData
import Foundation

@Model class UpdateHistory: ModelProtocol {
    @Attribute(.unique) var id: UUID
    var tableString: String
    var userId: UUID
    var timestamp: Date
    var createdAt: Date
    var updatedAt: Date
    var deletedAt: Date?
    
    init(id: UUID = UUID(), tableString: String, userId: UUID, timestamp: Date, createdAt: Date = Date(), updatedAt: Date = Date(), deletedAt: Date? = nil) {
        self.id = id
        self.tableString = tableString
        self.userId = userId
        self.timestamp = timestamp
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
    }
    
    func toDTO() -> UpdateHistoryDTO {
        UpdateHistoryDTO(id: id, tableString: tableString, userId: userId, timestamp: timestamp, createdAt: createdAt, updatedAt: updatedAt, deletedAt: deletedAt)
    }
}
