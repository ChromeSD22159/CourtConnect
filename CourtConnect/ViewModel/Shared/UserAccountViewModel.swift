//
//  UserAccountViewModel.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 23.01.25.
//
import Supabase
import Foundation
 
/*
@MainActor
@Observable class UserAccountViewModel: ObservableObject {
    var repository: BaseRepository
    var userId: UUID?
    var accounts: [UserAccount] = []
    var isCreateRoleSheet = false 
    
    init(repository: BaseRepository, userId: UUID?) {
        self.repository = repository
        self.userId = userId
    }
    

    private func getLastSyncDate(userId: UUID) throws -> Date {
        return try repository.syncHistoryRepository.getLastSyncDate(for: .userAccount, userId: userId).timestamp
    }
     
    func getAllFromDatabase() {
        guard let userId = userId else { return }
        do {
            self.accounts = try repository.accountRepository.getAllAccounts(userId: userId)
        } catch {
            print(error)
        }
    }
    
    func getCurrentAccount() -> UserAccount? {
        do {
            guard let userAccount = LocalStorageService.shared.user else { return nil }
            
            return try repository.accountRepository.getAccount(id: userAccount.id)
        } catch {
            return nil
        }
    }
      
    func hasBothRoles(role1: String = UserRole.player.rawValue, role2: String = UserRole.trainer.rawValue) -> Bool {
        let rolesSet = Set(accounts.map { $0.role })
        return rolesSet.contains(role1) && rolesSet.contains(role2)
    }
    
    func deleteUserAccount(userAccount: UserAccount) { 
        Task {
            do {
                try repository.accountRepository.softDelete(item: userAccount)
                
                getAllFromDatabase()
            } catch {
                getAllFromDatabase()
            }
        }
    }
    
    func debugdelete() {
        try? repository.accountRepository.debugDelete()
        self.getAllFromDatabase()
    }
    
    private func resetInputs() {
        self.role = .player
        self.position = .center
    }
    
    // Remote
    func sendToServer(account: UserAccount) async throws {
        try await repository.accountRepository.sendToBackend(item: account)
    }
    
    func importAccountsAfterLastSyncFromBackend() {
        guard let userId = userId else { return }
        Task {
            do {
                let lastSync = try getLastSyncDate(userId: userId)
                let result = try await repository.accountRepository.fetchFromServer(after: lastSync)
                
                for account in result {
                    try repository.accountRepository.usert(item: account.toModel())
                }
                
                try self.repository.syncHistoryRepository.insertLastSyncTimestamp(for: .userAccount, userId: userId)
                
                self.getAllFromDatabase()
            } catch {
                self.getAllFromDatabase()
            }
        }
    }
    
    func sendUpdatedAfterLastSyncToBackend() {
        guard let userId = userId else { return }
        Task {
            do {
                let lastSync = try getLastSyncDate(userId: userId)
                await repository.accountRepository.sendUpdatedAfterLastSyncToBackend(userId: userId, lastSync: lastSync)
            } catch {
                print("cannot send")
            }
        }
    }
} 
*/
