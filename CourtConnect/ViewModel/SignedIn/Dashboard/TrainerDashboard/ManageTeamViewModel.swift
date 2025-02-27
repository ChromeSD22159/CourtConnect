//
//  ManageTeamViewModel.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 07.02.25.
//
import Foundation
import Auth
import UIKit

@Observable class ManageTeamViewModel: AuthProtocol, QRCodeProtocol {
    var repository: BaseRepository = Repository.shared
    var user: User?
    var userAccount: UserAccount?
    var userProfile: UserProfile?
    var currentTeam: Team?
    
    var teamPlayer: [TeamMemberProfile] = []
    var teamTrainer: [TeamMemberProfile] = []
    
    var isShowQrSheet = false
    var joinCode: String = ""
    var qrCode: UIImage?
    private var currentBrightness: CGFloat?
    
    var isGenerateNewCodeSheet = false
    
    func inizialize() {
        self.getUser()
        self.getUserAccount()
        self.getUserProfile()
        self.getTeam()
        self.getTeamMember() 
    }
    
    func getTeamMember() {
        do {
            var teamPlayer: [TeamMemberProfile] = []
            var teamTrainer: [TeamMemberProfile] = []
            
            guard let currentTeam = currentTeam else { throw TeamError.teamNotFound }
            let teamMember = try repository.teamRepository.getTeamMembers(for: currentTeam.id)
            
            for member in teamMember {
                if let userAccount = try repository.accountRepository.getAccount(id: member.userAccountId),
                   let userProfil = try repository.userRepository.getUserProfileFromDatabase(userId: userAccount.userId) {
                    
                    if userAccount.roleEnum == .player {
                        teamPlayer.append(TeamMemberProfile(userProfile: userProfil, teamMember: member))
                    }
                    if userAccount.roleEnum == .coach {
                        teamTrainer.append(TeamMemberProfile(userProfile: userProfil, teamMember: member))
                    }
                }
            }
            
            self.teamPlayer = teamPlayer
            self.teamTrainer = teamTrainer
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
    
    func kickMember(teamMember: TeamMember) {
        Task {
            defer {
                inizialize()
            }
            do {
                guard let userAccount = try repository.accountRepository.getAccount(id: teamMember.userAccountId) else {
                    return
                }
                
                userAccount.teamId = nil
                userAccount.updatedAt = Date()
                 
                teamMember.deletedAt = Date()
                teamMember.updatedAt = Date()
                
                // SAVE LOCAL
                repository.teamRepository.upsertlocal(item: teamMember, table: .teamMember, userId: userAccount.userId)
                repository.teamRepository.upsertlocal(item: userAccount, table: .userAccount, userId: userAccount.userId)
                
                // SAVE REMOTE
                try await repository.teamRepository.upsertTeamMemberRemote(teamMember: teamMember)
                try await repository.accountRepository.sendToBackend(item: userAccount)
            }
        }
    }
    
    func readQRCode() {
        if let currentTeam = currentTeam {
            joinCode = currentTeam.joinCode
            qrCode = QRCodeHelper().generateQRCode(from: currentTeam.joinCode)
        }
    }
    
    func showQrSheet() {
        isShowQrSheet = true
        currentBrightness = UIScreen.main.brightness
        UIScreen.main.brightness = 1.0
    }
    
    func closeQrSheet() {
        isShowQrSheet = false
        guard let currentBrightness = currentBrightness else { return }
        UIScreen.main.brightness = currentBrightness
    }
}
