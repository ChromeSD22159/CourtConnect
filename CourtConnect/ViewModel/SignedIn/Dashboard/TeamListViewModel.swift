//
//  TeamListViewModel.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 29.01.25.
//
import Foundation

@MainActor
@Observable class TeamListViewModel: ObservableObject {
    var showJoinTeamAlert: Bool = false
    var searchTeamName: String = ""
    var isSearchBar: Bool  = false
    var foundTeams: [TeamDTO] = []
    var selectedTeam: TeamDTO?
    
    let repository: BaseRepository
    
    init(repository: BaseRepository) {
        self.repository = repository
    }
    
    func searchTeam() {
        Task {
            do {
                foundTeams = try await repository.teamRepository.searchTeamByName(name: searchTeamName) 
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func resetFoundTeams() {
        foundTeams = []
    }
    
    func requestTeam(userAccount: UserAccount) async throws {
        guard let selectedTeam = selectedTeam else { throw TeamError.noTeamFoundwithThisJoinCode }
        let newRequest = Requests(accountId: userAccount.id, teamId: selectedTeam.id, createdAt: Date(), updatedAt: Date())
        try await repository.teamRepository.requestTeam(request: newRequest)
    }
}
