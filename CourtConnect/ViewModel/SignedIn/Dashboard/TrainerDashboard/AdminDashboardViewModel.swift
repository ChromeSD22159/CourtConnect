//
//  AdminDashboardViewModel.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 11.02.25.
//
import Foundation
import Auth

@MainActor @Observable class AdminDashboardViewModel: AuthProtocol {
    var repository: BaseRepository = Repository.shared
    let errorHandler: ErrorHandlerViewModel = ErrorHandlerViewModel.shared
    let messagehandler: InAppMessagehandlerViewModel = InAppMessagehandlerViewModel.shared
      
    var user: User?
    var userAccount: UserAccount?
    var userProfile: UserProfile?
    var currentTeam: Team?
    
    var teamName = ""
    var isDeleteTeamDialog = false
    var isAddAdminSheet = false
    
    var teamAdmin: [TeamAdminProfile] = []
    var teamTrainer: [TeamMemberProfile] = []
    
    func inizialze() {
        self.inizializeAuth()
         
        self.getAllTeamAdmins()
        self.getAllTeamMemberAvaibleToBeAdmin()
        self.setTeamName()
    } 
    
    func deleteTeam() {
        Task {
            do {
                guard let currentTeam = currentTeam else { throw TeamError.teamNotFound }
                guard let userId = user?.id else { throw UserError.userIdNotFound }
                
                try repository.teamRepository.softDelete(team: currentTeam, userId: userId)
            } catch {
                errorHandler.handleError(error: error)
            }
        }
    }
    
    func save() {
        Task {
            do {
                guard !teamName.isEmpty else { throw TeamError.teamNameEmtpy }
                guard teamName.count >= 4 else { throw TeamError.teamNameLessCharacter }
                currentTeam?.teamName = teamName
                
                guard let currentTeam = currentTeam else { return }
                 
                try await repository.teamRepository.upsertTeamRemote(team: currentTeam)
                
                messagehandler.handleMessage(message: InAppMessage(title: "Saved!"))
            } catch {
                errorHandler.handleError(error: error)
            }
        }
    }
    
    func setTeamName() {
        guard let teamName = currentTeam?.teamName else { return }
        self.teamName = teamName
    }
     
    func getAllTeamMemberAvaibleToBeAdmin() {
        do {
            
            guard let currentTeam = currentTeam else { return }
            let localMember = try repository.teamRepository.getTeamMembers(for: currentTeam.id, role: .trainer)
            
            var teamMemberProfiles: [TeamMemberProfile] = []
            
            for member in localMember {
                do {
                    let userAccount = try repository.accountRepository.getAccount(id: member.userAccountId)
                    let admin = teamAdmin.first { $0.teamAdmin.userAccountId == userAccount?.id }
                    guard admin == nil else { return }
                    guard let userId = userAccount?.userId,
                          let userProfile = try repository.userRepository.getUserProfileFromDatabase(userId: userId) else {
                        continue
                    }
                    let teamMemberProfile = TeamMemberProfile(userProfile: userProfile, teamMember: member)
                     
                    teamMemberProfiles.append(teamMemberProfile)
                } catch {
                    print("Error fetching user profile: \(error)")
                }
            }
            
            self.teamTrainer = teamMemberProfiles
        } catch {
            print(error)
        }
    }
    
    func getAllTeamAdmins() {
        do {
            guard let currentTeam = currentTeam else { return }
            let localMember = try repository.teamRepository.getTeamAdmins(for: currentTeam.id)
            
            var teamAdminProfiles: [TeamAdminProfile] = []
            
            for member in localMember {
                do {
                    let userAccount = try repository.accountRepository.getAccount(id: member.userAccountId)
                    guard let userId = userAccount?.userId,
                          let userProfile = try repository.userRepository.getUserProfileFromDatabase(userId: userId) else {
                        continue
                    }
                    let teamAdminProfile = TeamAdminProfile(userProfile: userProfile, teamAdmin: member)
                    teamAdminProfiles.append(teamAdminProfile)
                } catch {
                    print("Error fetching user profile: \(error)")
                }
            }
            
            self.teamAdmin = teamAdminProfiles
        } catch {
            print(error)
        }
    }
    
    func addTrainerToAdmin(trainer: TeamMemberProfile) {
        guard let currentTeam = currentTeam else { return }
        guard let userId = user?.id else { return }
        let newAdmin = TeamAdmin(teamId: currentTeam.id, userAccountId: trainer.teamMember.userAccountId, role: UserRole.admin.rawValue, createdAt: Date(), updatedAt: Date())
        
        Task {
            defer {
                self.getAllTeamAdmins()
                self.getAllTeamMemberAvaibleToBeAdmin()
                isAddAdminSheet.toggle()
            }
            do {
                try await repository.teamRepository.insertTeamAdmin(newAdmin: newAdmin, userId: userId)
            } catch {
                errorHandler.handleError(error: error)
            }
        }
    }
    
    func removeFromAdmin(admin: TeamAdmin) {
        defer {
            self.getAllTeamAdmins()
            self.getAllTeamMemberAvaibleToBeAdmin()
        }
        do {
            guard let userId = user?.id else { return }
            try repository.teamRepository.softDelete(teamAdmin: admin, userId: userId)
        } catch {
            errorHandler.handleError(error: error)
        }
    }
}
