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
     
    func getAllFromDatabase() {
        guard let userId = userId else { return }
        do {
            self.accounts = try repository.accountRepository.getAllAccountsFromDatabase(userId: userId)
        } catch {
            print(error)
        }
    }
    
    func getCurrentAccount() -> UserAccount? {
        do {
            guard let userAccountId = LocalStorageService.shared.userAccountId, let id = UUID(uuidString: userAccountId) else { return nil }
            
            return try repository.accountRepository.getAccountsFromDatabase(id: id)
        } catch {
            return nil
        }
    }
    
    func insertAccount(isComplete: @escaping (Result<UserAccount, Error>) -> Void) {
        guard let userId = userId else { return isComplete(.failure(UserError.userIdNotFound)) }
        
        let account = UserAccount(userId: userId, teamId: "", position: position.rawValue, role: role.rawValue, createdAt: Date(), updatedAt: Date())
        
        Task {
            do {
                let lastSync: Date = try repository.syncHistoryRepository.getLastSyncDate(for: DatabaseTable.userAccount, userId: userId)?.timestamp ?? repository.syncHistoryRepository.defaultDate
                
                try await repository.accountRepository.insertDatabaseAndSync(account: account, lastSync: lastSync)
                
                self.accounts = try repository.accountRepository.getAllAccountsFromDatabase(userId: userId)
                
                isCreateRoleSheet.toggle()
                 
                LocalStorageService.shared.userAccountId = account.id.uuidString
                
                isComplete(.success(account))
            } catch {
                isComplete(.failure(UserError.userIdNotFound))
            }
        }
    }
    
    func syncAccounts() {
        guard let userId = userId else { return print("no user") }
        Task {
            let lastSync: Date = try repository.syncHistoryRepository.getLastSyncDate(for: DatabaseTable.userAccount, userId: userId)?.timestamp ?? repository.syncHistoryRepository.defaultDate
            
            try await repository.accountRepository.syncAllAfterTimeStamp(userId: userId, lastSync: lastSync)
            
            getAllFromDatabase()
        }
    }
    
    func hasBothRoles(role1: String = UserRole.player.rawValue, role2: String = UserRole.trainer.rawValue) -> Bool {
        let rolesSet = Set(accounts.map { $0.role })
        return rolesSet.contains(role1) && rolesSet.contains(role2)
    }
    
    private func resetInputs() {
        self.role = .player
        self.position = .center
    }
} 
