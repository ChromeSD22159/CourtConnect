//
//  AccountRepository.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 23.01.25.
//

import SwiftData
import SwiftUI 
 
class AccountRepository: SyncronizationProtocol {
    
    var backendClient = BackendClient.shared
    var container: ModelContainer
    
    init(container: ModelContainer) {
        self.container = container
    }
    
    // MARK: - Local
    func usert(item: UserAccount) throws {
        container.mainContext.insert(item)
        try container.mainContext.save()
    }
    
    func insert(termin:Termin) {
        container.mainContext.insert(termin)
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
        let predicate = #Predicate<Attendance> { $0.userAccountId == userAccountId && $0.attendanceStatus == statusString }
        let fetchDescriptor = FetchDescriptor(predicate: predicate)
        let result = try container.mainContext.fetch(fetchDescriptor)
        return result
    }
    
    func softDelete(item: UserAccount) throws {
        item.updatedAt = Date()
        item.deletedAt = Date()
        
        try usert(item: item)
    } 
    
    // MARK: SYNCING
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
