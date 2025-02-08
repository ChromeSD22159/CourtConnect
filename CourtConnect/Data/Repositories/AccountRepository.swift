//
//  AccountRepository.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 23.01.25.
//

import SwiftData
import SwiftUI 
 
@MainActor class AccountRepository {
    
    var backendClient = BackendClient.shared
    var container: ModelContainer
    
    init(container: ModelContainer) {
        self.container = container
    }
    
    // MARK: - Local
    func usert<T: ModelProtocol>(item: T, table: DatabaseTable, userId: UUID) throws {
        // 1. Daten immer lokal in Core Data speichern
           container.mainContext.insert(item)
           let newSyncHistoryTimeStamp = SyncHistory(table: .document, userId: userId)
           container.mainContext.insert(newSyncHistoryTimeStamp)
           try container.mainContext.save()
 
           Task {
               do {
                   try await SupabaseService.upsertWithOutResult(item: item.toDTO(), table: .userAccount, onConflict: "id")
               } catch {
                   throw error
               }
           }
       }
    
    func insert(termin:Termin, table: DatabaseTable, userId: UUID) throws {
        container.mainContext.insert(termin)
        let newSyncHistoryTimeStamp = SyncHistory(table: .document, userId: userId)
        container.mainContext.insert(newSyncHistoryTimeStamp)
        try container.mainContext.save()
        
        Task {
            do {
                try await SupabaseService.upsertWithOutResult(item: termin.toDTO(), table: .termin, onConflict: "id")
            } catch {
                throw error
            }
        }
    }
    
    func getAllAccounts(userId: UUID) throws -> [UserAccount] {
        let predicate = #Predicate<UserAccount> { $0.userId == userId && $0.deletedAt == nil }
        let fetchDescruptor = FetchDescriptor<UserAccount>(predicate: predicate)
        let resul = try container.mainContext.fetch(fetchDescruptor)
        return resul
    }
    
    func getAccountsAfterTimeStamp(userId: UUID, lastSync: Date) throws -> [UserAccount] {
        let predicate = #Predicate<UserAccount> { $0.userId == userId && $0.updatedAt > lastSync }
        let fetchDescruptor = FetchDescriptor<UserAccount>(predicate: predicate)
        let result = try container.mainContext.fetch(fetchDescruptor)
        return result
    }
    
    func getAccount(userId: UUID) throws -> UserAccount? {
        let predicate = #Predicate<UserAccount> { $0.userId == userId && $0.deletedAt == nil }
        let fetchDescruptor = FetchDescriptor<UserAccount>(predicate: predicate)
        let resul = try container.mainContext.fetch(fetchDescruptor).first
        return resul
    }
    
    func getAccount(id: UUID) throws -> UserAccount? {
        let predicate = #Predicate<UserAccount> { $0.id == id && $0.deletedAt == nil }
        let fetchDescruptor = FetchDescriptor<UserAccount>(predicate: predicate)
        let result = try container.mainContext.fetch(fetchDescruptor).first
        return result
    }
    
    func getAccountPendingAttendances(for userAccountId: UUID) throws -> [Attendance] {
        let statusString = AttendanceStatus.pending.rawValue
        let today = Date()
        let predicate = #Predicate<Attendance> { $0.startTime > today && $0.userAccountId == userAccountId && $0.attendanceStatus == statusString }
        let fetchDescriptor = FetchDescriptor(predicate: predicate)
        let result = try container.mainContext.fetch(fetchDescriptor)
        return result
    }
    
    func softDelete(item: UserAccount) throws {
        item.updatedAt = Date()
        item.deletedAt = Date()
        
        try usert(item: item, table: .userAccount, userId: item.userId)
    }
    
    // MARK: SYNCING
    #warning("REMOVE REFACTOR")
    func sendUpdatedAfterLastSyncToBackend(userId: UUID, lastSync: Date) async {
        Task {
            do {
                try await Task.sleep(for: .seconds(1))
                
                let predicate = #Predicate<UserAccount> { $0.userId == userId && $0.updatedAt > lastSync }
                let fetchDescriptor = FetchDescriptor<UserAccount>(predicate: predicate)
                let result = try container.mainContext.fetch(fetchDescriptor)

                for account in result {
                    try await self.sendToBackend(item: account)
                }
            } catch {
                print("cannot send: \(error)")
            }
        }
    }
    
    #warning("REMOVE REFACTOR")
    func sendToBackend(item: UserAccount) async throws {
        try await backendClient.supabase
            .from(DatabaseTable.userAccount.rawValue)
            .upsert(item.toDTO(), onConflict: "id")
            .execute()
            .value
    }
    
    #warning("REMOVE REFACTOR")
    func fetchFromServer(after: Date) async throws -> [UserAccountDTO] {
        return try await backendClient.supabase
            .from(DatabaseTable.userAccount.rawValue)
            .select()
            .gte("updatedAt", value: after)
            .execute()
            .value
    }
}
