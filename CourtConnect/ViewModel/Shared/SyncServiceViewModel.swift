//
//  SyncServiceViewModel.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 27.01.25.
//
import Foundation
 
@MainActor
@Observable class SyncServiceViewModel {
    var backendClient = BackendClient.shared
    let repository: BaseRepository
    
    init(backendClient: BackendClient = BackendClient.shared) {
        self.backendClient = backendClient
        self.repository = Repository.shared
    }
    
    func syncAllTablesAfterLastSync(userId: UUID) async throws {
        let databasesToSync: [(DatabaseTable, Date)] = try await repository.syncHistoryRepository.databasesToSync(userId: userId)
        
        print("Tables to Sync: \(databasesToSync.count)")
        
        for (table, lastSync) in databasesToSync {
            let result = try await repository.syncHistoryRepository.getUpdatedRows(for: table, lastSync: lastSync, type: table.remoteModel)
            
            try result.forEach { item in
                try repository.syncHistoryRepository.inserData(dto: item)
            }
            
            if !result.isEmpty {
                try repository.syncHistoryRepository.insertLastSyncTimestamp(for: table, userId: userId)
                print("\(table.rawValue) - reseceived \(result.count)")
            }
        }
    }
    
    func fetchAllTables(userId: UUID) async throws {
        let defaultData = Calendar.current.date(byAdding: .year, value: -10, to: Date())!
        
        for (table) in DatabaseTable.tablesToSync {
            let result = try await repository.syncHistoryRepository.getUpdatedRows(for: table, lastSync: defaultData, type: table.remoteModel)
            
            try result.forEach { item in
                try repository.syncHistoryRepository.inserData(dto: item)
            }
            
            if !result.isEmpty {
                try repository.syncHistoryRepository.insertLastSyncTimestamp(for: table, userId: userId)
                print("\(table.rawValue) - reseceived \(result.count)")
            }
        }
    }
    
    func sendAllData(userId: UUID) async throws {
        let allTables = try repository.syncHistoryRepository.getLastSyncTimestampsForAllTables(userId: userId)
         
        for (table, lastSync) in allTables {
            let allLocalChange = try repository.syncHistoryRepository.getAllItems(for: table, lastSync: lastSync, type: table.localModel)
            
            for item in allLocalChange {
                let _ = try await repository.syncHistoryRepository.sendUpdatesToServer(for: table, data: item.toDTO())
            }
            
            if !allLocalChange.isEmpty { 
                print("\(table.rawValue) - send \(allLocalChange.count)")
            }
        }
    }
}
