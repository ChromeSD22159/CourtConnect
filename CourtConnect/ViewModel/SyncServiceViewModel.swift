//
//  SyncServiceViewModel.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 27.01.25.
//
import Foundation

@MainActor
@Observable
class SyncServiceViewModel: ObservableObject {
    var backendClient = BackendClient.shared
    let repository: Repository
    
    init(backendClient: BackendClient = BackendClient.shared, repository: Repository) {
        self.backendClient = backendClient
        self.repository = repository
    }
    
    func syncAllTables(userId: UUID) async throws {
        let databasesToSync: [(DatabaseTable, Date)] = try await repository.syncHistoryRepository.databasesToSync(userId: userId)
        
        print("Tables to Sync: \(databasesToSync.count)")
        
        for (table, lastSync) in databasesToSync {
            let result = try await repository.syncHistoryRepository.getUpdatedRows(for: table, lastSync: lastSync, type: table.remoteModel)
           
            try result.forEach { item in
                try repository.syncHistoryRepository.inserData(dto: item)
            }
            
            try repository.syncHistoryRepository.insertLastSyncTimestamp(for: table, userId: userId)
        }
    }
    
    func sendAllData(userId: UUID) async throws {
        let allTables = try repository.syncHistoryRepository.getLastSyncTimestampsForAllTables(userId: userId)
        
        for (table, lastSync) in allTables {
            let allLocalChange = try repository.syncHistoryRepository.getAllItems(for: table, lastSync: lastSync, type: table.localModel)
                
            for item in allLocalChange {
                try await repository.syncHistoryRepository.sendUpdatesToServer(for: table, data: item.toDTO())
            }
            
            try await repository.syncHistoryRepository.insertUpdateTimestampTable(for: table, userId: userId)
        }
    }
}
