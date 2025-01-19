//
//  SyncHistory.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 19.01.25.
//
import SwiftData
import Foundation

@Model class SyncHistory: Identifiable {
    @Attribute(.unique) var id: UUID
    var table: String
    var userId: String
    var timestamp: Date
    
    init(id: UUID = UUID(), table: String, userId: String, timestamp: Date = Date()) {
        self.id = id
        self.table = table
        self.userId = userId
        self.timestamp = timestamp
    }
}
