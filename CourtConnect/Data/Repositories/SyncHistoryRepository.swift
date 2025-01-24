//
//  SyncHistoryRepository.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 19.01.25.
//
import SwiftData
import Foundation

@MainActor
class SyncHistoryRepository {
    let type: RepositoryType
    let container: ModelContainer 
    let defaultStartDate: Date = Calendar.current.date(byAdding: .year, value: -10, to: Date())!
    
    init(container: ModelContainer, type: RepositoryType) {
        self.type = type
        self.container = container
    }
      
    func getLastSyncDate(for table: DatabaseTable, userId: String) throws -> SyncHistory? {
        let tableString: String = table.rawValue
        let predicate = #Predicate<SyncHistory> { histery in
            histery.userId == userId && histery.table == tableString
        }
        
        let sortBy = [SortDescriptor(\SyncHistory.timestamp, order: .reverse)]
        
        let fetchDescriptor = FetchDescriptor(predicate: predicate, sortBy: sortBy)
        
        return try container.mainContext.fetch(fetchDescriptor).first
    }
    
    func insertTimestamp(for table: DatabaseTable, userId: String) throws {
        let new = SyncHistory(table: table.rawValue, userId: userId)
        container.mainContext.insert(new)
        try container.mainContext.save()
    }
    
    func insertTimestamp(timestamp: SyncHistory) throws { 
        container.mainContext.insert(timestamp)
        try container.mainContext.save()
    }
    
    var defaultDate: Date {
        let cal = Calendar.current
        return cal.date(byAdding: .year, value: -30, to: Date())!
    }
}
