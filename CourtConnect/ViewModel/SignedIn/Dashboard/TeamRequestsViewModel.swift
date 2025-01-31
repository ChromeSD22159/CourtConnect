//
//  TeamRequestsViewModel.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 30.01.25.
//
import Foundation

@Observable @MainActor class TeamRequestsViewModel {
    var isLoading = false
    var requests: [RequestUser] = []
    var userProfiles: [UserProfile] = []
    
    let repository: BaseRepository
    let teamId: UUID
    
    init(repository: BaseRepository, teamId: UUID) {
        self.repository = repository
        self.teamId = teamId
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
            try repository.teamRepository.upsertLocal(item: request)
            
            Task {
                await syncRemoteUseraccounts(accountId: request.accountId)
            }
        }
    }
    
    private func syncRemoteUserProfiles(userId: UUID) async {
        do {
            let foundUserProfileDtoOrNil: [UserProfileDTO] = try await SupabaseService.getAllFromTable(table: .userProfile, match: ["userId": userId.uuidString])
            if let foundUserProfile = foundUserProfileDtoOrNil.first?.toModel() {
                try repository.teamRepository.upsertLocal(item: foundUserProfile)
            }
        } catch {
            print("syncRemoteUserProfiles: \(error)")
        }
    }
    
    private func syncRemoteUseraccounts(accountId: UUID) async {
        do {
            let foundUserAccountDtoOrNil: [UserAccountDTO] = try await SupabaseService.getAllFromTable(table: .userAccount, match: ["id": accountId.uuidString])
            if let foundUserAccount = foundUserAccountDtoOrNil.first?.toModel() {
                try repository.teamRepository.upsertLocal(item: foundUserAccount)
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
            let newMember = TeamMember(userAccountId: request.accountId, teamId: request.teamId, role: userAccount.role, createdAt: Date(), updatedAt: Date())
            
            try repository.teamRepository.softDelete(request: request)
            await getLocalRequests()
        
            try repository.teamRepository.upsertLocal(item: newMember)
        
            try await SupabaseService.upsertWithOutResult(item: newMember.toDTO(), table: .teamMember, onConflict: "id")
            try await SupabaseService.upsertWithOutResult(item: request.toDTO(), table: .request, onConflict: "id")
        }
    }
    
    func rejectRequest(request: Requests) {
        Task {
            try repository.teamRepository.softDelete(request: request)
            await getLocalRequests()
            
            try await SupabaseService.upsertWithOutResult(item: request.toDTO(), table: .request, onConflict: "id")
        }
    }
}
