//
//  ManageTeamViewModel.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 07.02.25.
//
import Foundation
import Auth

@Observable @MainActor class ManageTeamViewModel: AuthProtocol {
    var repository: BaseRepository = Repository.shared
    var user: User?
    var userAccount: UserAccount?
    var userProfile: UserProfile?
    var currentTeam: Team?
    
    var teamPlayer: [TeamMemberProfile] = []
    var teamTrainer: [TeamMemberProfile] = []
    
    func inizialize() {
        self.getUser()
        self.getUserAccount()
        self.getUserProfile()
        self.getTeam()
        self.getTeamMember()
    }
    
    func getTeamMember() {
        do {
            guard let currentTeam = currentTeam else { throw TeamError.teamNotFound }
            let teamMember = try repository.teamRepository.getTeamMembers(for: currentTeam.id) 
           
            for member in teamMember {
                if let userAccount = try repository.accountRepository.getAccount(id: member.userAccountId),
                   let userProfil = try repository.userRepository.getUserProfileFromDatabase(userId: userAccount.userId) {
                    
                    if userAccount.roleEnum == .player {
                        self.teamPlayer.append(TeamMemberProfile(userProfile: userProfil, teamMember: member))
                    }
                    if userAccount.roleEnum == .coach {
                        self.teamTrainer.append(TeamMemberProfile(userProfile: userProfil, teamMember: member))
                        print(teamTrainer.count)
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
    
    func kickMember() {
        // TODO: 
    }
}

struct ShirtNumberOption: Identifiable {
    let id = UUID()
    let number: Int
}
