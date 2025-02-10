//
//  SyncHistoryProtocol.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 09.02.25.
//
import Supabase
import Foundation

@MainActor protocol SyncHistoryProtocol {
    var repository: BaseRepository { get set }
}

extension SyncHistoryProtocol {
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
    
    func syncAllTables(userId: UUID) async throws {
        let databasesToSync: [(DatabaseTable, Date)] = try await repository.syncHistoryRepository.databasesToFetch(userId: userId)
        
        print("Tables to Fetch: \(databasesToSync.count)")
        
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
