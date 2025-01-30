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
                print(foundTeams.count)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func resetFoundTeams() {
        foundTeams = []
    }
    
    func joinTeam(team: TeamDTO) {
    }
} 
