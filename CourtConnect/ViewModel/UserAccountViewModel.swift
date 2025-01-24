//
//  UserAccountViewModel.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 23.01.25.
//
import FirebaseAuth
@Observable
@MainActor
class UserAccountViewModel: ObservableObject {
    private let repository: Repository
    private var userId: String?
    
    var accounts: [UserAccount] = []
    
    var isCreateRoleSheet = false
    
    /// SHEET
    var role: UserRole = .player
    var position: BasketballPosition = .center
    
    init(repository: Repository, userId: String?) {
        self.repository = repository
        self.userId = userId
    }
    
    private func getLastSyncDate(userId: String) throws -> Date {
        return try repository.syncHistoryRepository.getLastSyncDate(for: .userAccount, userId: userId)?.timestamp ?? repository.syncHistoryRepository.defaultDate
    }
    
    func insertAccount() throws -> UserAccount? {
        guard let userId = userId else { return nil }
        
        let account = UserAccount(userId: userId, teamId: "", position: position.rawValue, role: role.rawValue, createdAt: Date(), updatedAt: Date())
        
        try repository.accountRepository.usert(account: account)
        
        self.getAllFromDatabase()
        
        isCreateRoleSheet.toggle()
        
        return account
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
            guard let userAccountId = LocalStorageService.shared.userAccountId, let id = UUID(uuidString: userAccountId) else { return nil }
            
            return try repository.accountRepository.getAccount(id: id)
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
                try repository.accountRepository.softDelete(account: userAccount)
                
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
        try await repository.accountRepository.sendToBackend(account: account)
    }
    
    func importAccountsAfterLastSyncFromBackend() {
        guard let userId = userId else { return }
        Task {
            do {
                let lastSync = try getLastSyncDate(userId: userId)
                let result = try await repository.accountRepository.fetchFromServer(after: lastSync)
                
                for account in result {
                    try repository.accountRepository.usert(account: account.toUserAccount())
                }
                
                try self.repository.syncHistoryRepository.insertTimestamp(for: .userAccount, userId: userId)
                
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
