//
//  TeamRequestsViewModel.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 30.01.25.
//
import Foundation
import Auth

@Observable @MainActor class TeamRequestsViewModel: AuthProtocol, SyncHistoryProtocol {
    var repository: BaseRepository = Repository.shared
    
    var user: User?
    var userAccount: UserAccount?
    var userProfile: UserProfile?
    var currentTeam: Team?
    var isfetching: Bool = false
    var isLoading = false
    var requests: [RequestUser] = []
    var userProfiles: [UserProfile] = []
     
    let teamId: UUID
    let userId: UUID
    
    init(repository: BaseRepository, teamId: UUID, userId: UUID) {
        self.repository = repository
        self.teamId = teamId
        self.userId = userId
    }
    
    func getLocalRequests() async {
        requests = []
        do {
            let requests = try repository.teamRepository.getTeamRequests(teamId: teamId)
            
            requests.forEach {
                getRequestedUser(accountId: $0.accountId, request: $0)
            }
        } catch {
            //
        }
    }
  
    func syncRemoteRequests() async throws {
        let requestsDTO: [RequestsDTO] = try await SupabaseService.getAllFromTable(table: .request, match: ["teamId": teamId.uuidString])
        
        let requests = requestsDTO.map { $0.toModel() }
        
        try requests.forEach { request in
            
            try repository.teamRepository.upsertLocal(item: request, table: .request, userId: userId)
            
            Task {
                await syncRemoteUseraccounts(accountId: request.accountId)
            }
        }
    }
    
    private func syncRemoteUserProfiles(userId: UUID) async {
        do {
            let foundUserProfileDtoOrNil: [UserProfileDTO] = try await SupabaseService.getAllFromTable(table: .userProfile, match: ["userId": userId.uuidString])
            if let foundUserProfile = foundUserProfileDtoOrNil.first?.toModel() {
                try repository.teamRepository.upsertLocal(item: foundUserProfile, table: .userProfile, userId: userId)
            }
        } catch {
            print("syncRemoteUserProfiles: \(error)")
        }
    }
    
    private func syncRemoteUseraccounts(accountId: UUID) async {
        do {
            let foundUserAccountDtoOrNil: [UserAccountDTO] = try await SupabaseService.getAllFromTable(table: .userAccount, match: ["id": accountId.uuidString])
            if let foundUserAccount = foundUserAccountDtoOrNil.first?.toModel() {
                try repository.teamRepository.upsertLocal(item: foundUserAccount, table: .userAccount, userId: foundUserAccount.userId)
                await syncRemoteUserProfiles(userId: foundUserAccount.userId)
            }
        } catch {
            print("syncRemoteUseraccounts: \(error)")
        }
    }
    
    private func getRequestedUser(accountId: UUID, request: Requests) {
        Task {
            do {
                let (userAccountOrNil, userProfileOrNil) = try await repository.userRepository.getRequestedUser(accountId: accountId)
                
                guard let userAccount = userAccountOrNil, let userProfile = userProfileOrNil else { return }
                 
                requests.append(RequestUser(teamID: request.teamId, userAccount: userAccount, userProfile: userProfile, request: request))
            } catch {
            }
        }
    }
    
    func grandRequest(request: Requests, userAccount: UserAccount) {
        Task {
            do {
                let newMember = TeamMember(userAccountId: request.accountId, teamId: request.teamId, shirtNumber: nil, position: "", role: userAccount.role, createdAt: Date(), updatedAt: Date())
                
                try repository.teamRepository.softDelete(request: request)
                await getLocalRequests()
            
                try await repository.teamRepository.insertTeamMember(newMember: newMember, userId: request.accountId)
                
                let account = try repository.accountRepository.getAccount(id: request.accountId)
                account?.teamId = teamId
                
                try await SupabaseService.upsertWithOutResult(item: newMember.toDTO(), table: .teamMember, onConflict: "id")
                try await SupabaseService.upsertWithOutResult(item: request.toDTO(), table: .request, onConflict: "id")
                
                guard let user = user else { throw UserError.userIdNotFound }
                try await self.syncAllTables(userId: user.id)
            } catch {
                ErrorHandlerViewModel.shared.handleError(error: error)
                print(error)
            }
        }
    }
    
    func rejectRequest(request: Requests) {
        Task {
            try repository.teamRepository.softDelete(request: request)
            await getLocalRequests()
            
            try await SupabaseService.upsertWithOutResult(item: request.toDTO(), table: .request, onConflict: "id")
        }
    }
    
    func fetchDataFromRemote() {
        Task {
            do {
                if let userId = user?.id {
                    try await syncAllTables(userId: userId)
                }
            } catch {
                print(error)
            }
        }
    }
}
