//
//  DashBoardViewModel.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 30.01.25.
//
import Foundation
import Auth

@Observable @MainActor class DashboardViewModel: AuthProtocol, SyncHistoryProtocol {
    var repository: BaseRepository = Repository.shared
    var user: User?
    var userProfile: UserProfile?
    var userAccount: UserAccount?
    var currentTeam: Team?
    var userAccounts: [UserAccount] = []
    var isfetching: Bool = false
    var isCreateRoleSheet = false
    
    init() {
        getLocalData()
    }
    
    func getLocalData() {
        inizializeAuth()
        getAllUserAccounts()
        getCurrentAccount()
    }
    
    func getCurrentAccount() {
        do {
            getAllUserAccounts()
            
            if let userAccountIdString = LocalStorageService.shared.userAccountId, let userAccountId = UUID(uuidString: userAccountIdString) {
                self.userAccount = try repository.accountRepository.getAccount(id: userAccountId)
            } else {
                if let userAccount = userAccounts.first {
                    self.userAccount = userAccount
                    LocalStorageService.shared.userAccountId = userAccount.id.uuidString
                }
            }
        } catch {
            print(error)
        }
    }
    
    func getAllUserAccounts() {
        do {
            guard let userId = user?.id else { return }
            let accs = try repository.accountRepository.getAllAccounts(userId: userId) 
            self.userAccounts = accs
        } catch {
            print(error)
        }
    }
    
    func setCurrentAccount(newAccount: UserAccount?) {
        userAccount = newAccount
        LocalStorageService.shared.userAccountId = newAccount?.id.uuidString
    }
    
    func fetchDataFromRemote() {
        Task {
            await fetchData()
            getLocalData()
        }
    }
}
