//
//  SyncHistoryProtocol.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 09.02.25.
//
import Supabase
import Foundation
import Auth

@MainActor protocol SyncHistoryProtocol: ObservableObject {
    var repository: BaseRepository { get set }
    var isfetching: Bool { get set }
    var user: User? { get set }
    func fetchDataFromRemote()
}

extension SyncHistoryProtocol {
    func syncAllTablesAfterLastSync(userId: UUID) async throws {
        isfetching.toggle()
        defer { isfetching.toggle() }
        do {
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
        } catch {
            throw error
        }
    }
    
    func syncAllTables(userId: UUID) async throws {
        isfetching.toggle()
        defer { isfetching.toggle() }
        do {
            let databasesToSync: [(DatabaseTable, Date)] = try await repository.syncHistoryRepository.databasesToFetch(userId: userId)
            
            print("Tables to Fetch: \(databasesToSync.count)")
            
            for (table, lastSync) in databasesToSync {
                
                do {
                    let result = try await repository.syncHistoryRepository.getUpdatedRows(for: table, lastSync: lastSync, type: table.remoteModel)
                    
                    try result.forEach { item in
                        try repository.syncHistoryRepository.inserData(dto: item)
                    }
                    
                    if !result.isEmpty {
                        try repository.syncHistoryRepository.insertLastSyncTimestamp(for: table, userId: userId)
                        print("\(table.rawValue) - reseceived \(result.count)")
                    }
                } catch {
                    print("\(table.rawValue) \(error)")
                }
            }
        } catch {
            throw error
        }
    }
    
    func sendAllData(userId: UUID) async throws {
        isfetching.toggle()
        defer { isfetching.toggle() }
        do {
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
        } catch {
            throw error
        }
    }
    
    func fetchData() async {
        do {
            if let userId = user?.id {
                try await syncAllTables(userId: userId)
            }
        } catch {
            print(error)
        }
    }
}
