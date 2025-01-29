//
//  SyncHistoryRepository.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 19.01.25.
//
import SwiftData
import Foundation

@MainActor struct SyncServiceRepository {
    let type: RepositoryType
    var backendClient = BackendClient.shared
    let container: ModelContainer
    let defaultSyncDate: Date = Calendar.current.date(byAdding: .year, value: -10, to: Date())!
    
    private var defaultDate: Date {
        let cal = Calendar.current
        return cal.date(byAdding: .year, value: -30, to: Date())!
    }
    
    init(container: ModelContainer, type: RepositoryType) {
        self.type = type
        self.container = container
    }
    
    /// SWIFT
    func getLastSyncDate(for table: DatabaseTable, userId: UUID) throws -> SyncHistory {
        let tableString: String = table.rawValue
        let predicate = #Predicate<SyncHistory> { histery in
            histery.userId == userId && histery.tableString == tableString
        }
        
        let sortBy = [SortDescriptor(\SyncHistory.timestamp, order: .reverse)]
        
        let fetchDescriptor = FetchDescriptor(predicate: predicate, sortBy: sortBy)
        
        return try container.mainContext.fetch(fetchDescriptor).first ?? SyncHistory(table: table, userId: userId, timestamp: self.defaultSyncDate)
    }
    
    func insertLastSyncTimestamp(for table: DatabaseTable, userId: UUID) throws {
        let new = SyncHistory(table: table, userId: userId)
        container.mainContext.insert(new)
        try container.mainContext.save()
    }
    
    func getLastSyncTimestampsForAllTables(userId: UUID) throws -> [(DatabaseTable, Date)] {
        var list: [(DatabaseTable, Date)] = []
        for table in DatabaseTable.allCases {
            if table == .updateHistory || table == .userOnline || table == .userProfile { continue }
            
            let entry = try getLastSyncDate(for: table, userId: userId)
            list.append((entry.table, entry.timestamp))
        }
        return list
    }
    
    func getAllItems<T: ModelProtocol>(for table: DatabaseTable, lastSync: Date, type: T.Type) throws -> [T] { 
        let predicate = #Predicate<T> { item in
            item.updatedAt > lastSync
        }
        
        let fetchDescriptor = FetchDescriptor(predicate: predicate)
        
        return try container.mainContext.fetch(fetchDescriptor)
    }
    
    /// BACKEND
    func insertUpdateTimestampTable(for table: DatabaseTable, userId: UUID) async throws {
        let entry = UpdateHistoryDTO(tableString: table.rawValue, userId: userId, timestamp: Date()) 
        
        try await backendClient.supabase
            .from(DatabaseTable.updateHistory.rawValue)
            .upsert(entry, onConflict: "tableString, userId")
            .execute()
    }

    func databasesToSync(userId: UUID) async throws -> [(DatabaseTable, Date)] {
        var tablesToSync: [(DatabaseTable, Date)] = []

        for table in DatabaseTable.allCases {
            if table == .updateHistory || table == .userOnline || table == .userProfile { continue }
            
            let lastLocalSync = try self.getLastSyncDate(for: table, userId: userId)
            
            if let lastUpdateOnRemote = try await self.getUpdatesTablesAfter(for: table, userId: userId) {
                if self.isSyncAble(local: lastLocalSync, remote: lastUpdateOnRemote) {
                    tablesToSync.append((table, lastLocalSync.timestamp))
                }
            }
        }
        
        return tablesToSync
    }

    private func getUpdatesTablesAfter(for table: DatabaseTable, userId: UUID) async throws -> UpdateHistoryDTO? {
        let result: [UpdateHistoryDTO] = try await backendClient.supabase
            .from(DatabaseTable.updateHistory.rawValue)
                .select()
                .eq("userId", value: userId.uuidString)
                .eq("tableString", value: table.rawValue)
                .execute()
                .value
        
        return result.first
    }
     
    private func isSyncAble(local: SyncHistory, remote: UpdateHistoryDTO) -> Bool {
        return local.timestamp < remote.timestamp
    }
    
    func inserData<T: DTOProtocol>(dto: T) throws {
        container.mainContext.insert(dto.toModel())
        try container.mainContext.save()
    }
    
    func getUpdatedRows<T: DTOProtocol & Decodable>(for table: DatabaseTable, lastSync: Date, type: T.Type) async throws -> [T] {
        return try await self.backendClient.supabase
            .from(table.rawValue)
            .select()
            .gte("updatedAt", value: lastSync)
            .execute()
            .value
    }
    
    func sendUpdatesToServer<T: DTOProtocol & Decodable>(for table: DatabaseTable, data: T) async throws {
        return try await self.backendClient.supabase
            .from(table.rawValue)
            .upsert(data, onConflict: "id")
            .execute()
            .value
    }
}  
