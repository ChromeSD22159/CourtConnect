//
//  CreateUserAccountViewModel.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 30.01.25.
//
import Foundation

@Observable @MainActor class CreateUserAccountViewModel {
    var repository: BaseRepository
    var userId: UUID
    
    var role: UserRole = .player
    var position: BasketballPosition = .center
    var accounts: [UserAccount] = []
    
    init(repository: BaseRepository, userId: UUID) {
        self.repository = repository
        self.userId = userId
    }
    
    func insertAccount() async throws {
        let account = UserAccount(userId: userId, teamId: nil, position: position.rawValue, role: role.rawValue, displayName: role.rawValue, createdAt: Date(), updatedAt: Date())
        
        try repository.accountRepository.usert(item: account)
        
        self.getAllFromDatabase()
        
        try await sendToServer(account: account)
        
        LocalStorageService.shared.userAccountId = account.id.uuidString
    }
    
    func getAllFromDatabase() {
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
