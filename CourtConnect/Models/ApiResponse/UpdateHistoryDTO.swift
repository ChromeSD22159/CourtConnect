//
//  UpdateHistoryDTO.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 27.01.25.
//
import Foundation
// UpdateHistory
struct UpdateHistoryDTO: Codable, DatabaseHistoryProtocol {
    var id: UUID
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
}

protocol DatabaseHistoryProtocol {
    var id: UUID { get set }
    var tableString: String { get set }
    var userId: UUID { get set }
    var timestamp: Date { get set }
}
