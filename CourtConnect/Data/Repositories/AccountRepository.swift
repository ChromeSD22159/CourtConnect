//
//  AccountRepository.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 23.01.25.
//

import SwiftData
import SwiftUI
import FirebaseAuth

@MainActor
class AccountRepository {
    let backendClient = BackendClient.shared
    let container: ModelContainer
    
    init(container: ModelContainer, type: RepositoryType) {
        self.container = container
    }
    
    // MARK: - SYNC LOGIC
    func insertDatabaseAndSync(account: UserAccount, lastSync: Date) async throws {
        account.updatedAt = Date()
        container.mainContext.insert(account)
        try container.mainContext.save()
         
        let found = try getAllAccountsAfterUpdateFromDatabase(userId: account.userId, lastSync: lastSync)
        
        try await syncAllAfterTimeStamp(accounts: found, userId: account.userId, lastSync: lastSync)
    }
     
    // MARK: - REMOTE
    func getAllAccountsAfterTimeStampFromBackend(userId: String, lastSync: Date) async throws -> [UserAccountDTO] {
        let result: [UserAccountDTO] = try await backendClient
            .supabase
            .from(DatabaseTable.userAccount.rawValue)
            .execute()
            .value
        
        return result
    }

    func syncAllAfterTimeStamp(accounts: [UserAccount] = [], userId: String, lastSync: Date) async throws {
        for account in accounts {
            try await backendClient
                .supabase
                .from(DatabaseTable.userAccount.rawValue)
                .upsert(account.toUserAccountDTO(), onConflict: "id")
                .execute()
        }
        
        let result = try await getAllAccountsAfterTimeStampFromBackend(userId: "", lastSync: lastSync)
        
        try result.forEach { resultAcc in
            container.mainContext.insert(resultAcc.toUserAccount())
            try container.mainContext.save()
        }
    }
    
    // MARK: - LOCAL
    func getAllAccountsFromDatabase(userId: String) throws -> [UserAccount] {
        let predicate = #Predicate<UserAccount> { account in
            account.userId == userId
        }
        
        let fetchDescriptor = FetchDescriptor(predicate: predicate)
        
        return try container.mainContext.fetch(fetchDescriptor)
    }
    
    func getAccountsFromDatabase(id: UUID) throws -> UserAccount? {
        let predicate = #Predicate<UserAccount> { account in
            account.id == id
        }
        
        let fetchDescriptor = FetchDescriptor(predicate: predicate)
        
        return try container.mainContext.fetch(fetchDescriptor).first
    }
    
    private func getAllAccountsAfterUpdateFromDatabase(userId: String, lastSync: Date) throws -> [UserAccount] {
        let predicate = #Predicate<UserAccount> { account in
            account.updatedAt > lastSync && account.userId == userId
        }
        
        let fetchDescriptor = FetchDescriptor(predicate: predicate)
        
        return try container.mainContext.fetch(fetchDescriptor)
    }
} 
