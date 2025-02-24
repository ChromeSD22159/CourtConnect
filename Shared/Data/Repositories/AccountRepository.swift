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
    
    func getAccount(id userAccountId: UUID) throws -> UserAccount? {
        let predicate = #Predicate<UserAccount> { $0.id == userAccountId && $0.deletedAt == nil }
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
    
    func isUserAdmin(account: UserAccount) -> Bool {
        do {
            let accoundId = account.id
            let predicate = #Predicate<TeamAdmin> { $0.userAccountId == accoundId && $0.deletedAt == nil }
            let fetchDescruptor = FetchDescriptor<TeamAdmin>(predicate: predicate)
            let resul = try container.mainContext.fetch(fetchDescruptor).first
            return resul != nil
        } catch {
            return false
        }
    }
    
    // MARK: SYNCING
    func sendToBackend(item: UserAccount) async throws {
        try await backendClient.supabase
            .from(DatabaseTable.userAccount.rawValue)
            .upsert(item.toDTO(), onConflict: "id")
            .execute()
            .value
    }
     
    func fetchFromServer(after: Date) async throws -> [UserAccountDTO] {
        return try await backendClient.supabase
            .from(DatabaseTable.userAccount.rawValue)
            .select()
            .gte("updatedAt", value: after)
            .execute()
            .value
    }
}
