//
//  TeamListViewModel.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 29.01.25.
//
import Foundation
import Auth

@MainActor
@Observable class TeamListViewModel: AuthProtocol, ObservableObject {
    var messagehandler = InAppMessagehandlerViewModel.shared
    var errorHandler = ErrorHandlerViewModel.shared
    var repository: BaseRepository = Repository.shared
    var user: Auth.User?
    var userAccount: UserAccount?
    var currentTeam: Team?
    var userProfile: UserProfile?
     
    var showJoinTeamAlert: Bool = false
    var searchTeamName: String = ""
    var isSearchBar: Bool  = false
    var foundTeams: [TeamDTO] = []
    var selectedTeam: TeamDTO?
     
    func searchTeam() {
        Task {
            do {
                guard !searchTeamName.isEmpty else { throw TeamError.searchInputIsNull }
                foundTeams = try await repository.teamRepository.searchTeamByName(name: searchTeamName)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func resetFoundTeams() {
        foundTeams = []
    }
    
    func requestTeam() async throws {
        guard let userAccount = userAccount else { throw UserError.userAccountNotFound }
        guard let selectedTeam = selectedTeam else { throw TeamError.noTeamFoundwithThisJoinCode }
        let newRequest = Requests(accountId: userAccount.id, teamId: selectedTeam.id, createdAt: Date(), updatedAt: Date())
        try await repository.teamRepository.requestTeam(request: newRequest)
    }
    
    func sendJoinRequest() {
        Task {
            do { 
                try await requestTeam()
                let msg = InAppMessage(title: "Request send!")
                messagehandler.handleMessage(message: msg)
            } catch {
                errorHandler.handleError(error: error)
            }
        }
    }
}
