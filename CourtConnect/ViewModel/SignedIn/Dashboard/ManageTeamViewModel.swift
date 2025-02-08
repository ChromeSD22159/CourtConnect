//
//  ManageTeamViewModel.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 07.02.25.
//
import Foundation

@Observable @MainActor class ManageTeamViewModel {
    let repository: BaseRepository
    let teamId: UUID
    
    var teamPlayer: [TeamMemberProfile] = []
    var teamTrainer: [TeamMemberProfile] = []
    
    init(repository: BaseRepository, teamId: UUID) {
        self.repository = repository
        self.teamId = teamId
        
        self.getTeamMember()
    }
    
    func getTeamMember() {
        do {
            let teamMember = try repository.teamRepository.getTeamMembers(for: teamId)
            
            for member in teamMember {
                if let userAccount = try repository.accountRepository.getAccount(id: member.userAccountId),
                   let userProfil = try repository.userRepository.getUserProfileFromDatabase(userId: userAccount.userId) {
                    
                    if userAccount.roleEnum == .player {
                        self.teamPlayer.append(TeamMemberProfile(userProfile: userProfil, teamMember: member))
                    }
                    if userAccount.roleEnum == .trainer {
                        self.teamTrainer.append(TeamMemberProfile(userProfile: userProfil, teamMember: member))
                    }
                }
            }
        } catch {
            print(error)
        }
    }
    
    func sendToBackend(teamMember: TeamMember) {
        Task {
            do {
                try await repository.teamRepository.upsertTeamMemberRemote(teamMember: teamMember)
            } catch {
                print(error)
            }
        }
    }
}

struct ShirtNumberOption: Identifiable {
    let id = UUID()
    let number: Int
}
