//
//  CreateUserAccountViewModel.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 30.01.25.
//
import Foundation

@Observable @MainActor class CreateUserAccountViewModel {
    var repository: BaseRepository
    var userId: UUID?
    var role: UserRole = .player
    var position: BasketballPosition = .center
    var accounts: [UserAccount] = []
    var isCreateRoleSheet = false
    
    init(repository: BaseRepository, userId: UUID? = nil) {
        self.repository = repository
        self.userId = userId
    }
    
    func insertAccount() throws -> UserAccount? {
        guard let userId = userId else { return nil }
        
        let account = UserAccount(userId: userId, teamId: nil, position: position.rawValue, role: role.rawValue, displayName: role.rawValue, createdAt: Date(), updatedAt: Date())
        
        try repository.accountRepository.usert(item: account)
        
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
    
    func sendToServer(account: UserAccount) async throws {
        try await repository.accountRepository.sendToBackend(item: account)
    }
}
