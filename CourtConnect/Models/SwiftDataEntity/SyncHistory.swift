//
//  SyncHistory.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 19.01.25.
//
import SwiftData
import Foundation
import Supabase

@Model class SyncHistory: Identifiable, DatabaseHistoryProtocol {
    @Attribute(.unique) var id: UUID
    var tableString: String
    var userId: UUID
    var timestamp: Date
    
    init(id: UUID = UUID(), table: DatabaseTable, userId: UUID, timestamp: Date = Date()) {
        self.id = id
        self.tableString = table.rawValue
        self.userId = userId
        self.timestamp = timestamp
    }
    
    var table: DatabaseTable {
       get {
           DatabaseTable(rawValue: tableString)!
       }
       set {
           tableString = newValue.rawValue
       }
   }
} 
