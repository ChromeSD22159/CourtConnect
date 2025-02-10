//
//  AdminDashboard.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 10.02.25.
//
import SwiftUI

struct AdminDashboard: View {
    @State var adminDashboardViewModel: AdminDashboardViewModel
    
    init(userId: UUID?, currentAccount: UserAccount?, currentTeam: Team?) {
        self.adminDashboardViewModel = AdminDashboardViewModel(userId: userId, currentAccount: currentAccount, currentTeam: currentTeam)
    }
    
    var body: some View {
        List {
            ListInfomationSection(text: "Here you can manage the team admins, change the team names or delete the team.")
            
            Section {
                // TODO: Stunden PDF Erstellen
                VStack(alignment: .leading) {
                    HStack {
                        Text("Dezember 2024")
                        Spacer()
                        Image(systemName: "square.and.arrow.up")
                    }
                    
                    Label("Add Report", systemImage: "plus")
                }
                .comeSoon()
            } header: {
                UpperCasedheadline(text: "Trainer Hour Report")
                    .comeSoon()
                    .comeSoonBadge()
            }
            
            Section {
                if adminDashboardViewModel.teamAdmin.isEmpty {
                    NoTeamMemberAvaible()
                } else {
                    ForEach(adminDashboardViewModel.teamAdmin) { admin in
                        Text(admin.userProfile.fullName)
                            .swipeActions {
                                Button("Remove Admin") {
                                    adminDashboardViewModel.removeFromAdmin(admin: admin.teamAdmin)
                                }
                            }
                    }
                }
                
                if !adminDashboardViewModel.teamTrainer.isEmpty {
                    Label("Add Admin", systemImage: "plus")
                        .onTapGesture {
                            adminDashboardViewModel.isAddAdminSheet.toggle()
                        }
                }
            } header: {
                UpperCasedheadline(text: "Team Admins")
            }
            
            Section {
                TextField("Change Team name", text: $adminDashboardViewModel.teamName, prompt: Text("Change Team name"))
                    .padding(.horizontal)
            } header: {
                UpperCasedheadline(text: "Change Team name")
            }
             
            Section {
                Label("Delete Team", systemImage: "trash")
                    .onTapGesture {
                        adminDashboardViewModel.isDeleteTeamDialog.toggle()
                    }
                    .confirmationDialog("Want delete the Team", isPresented: $adminDashboardViewModel.isDeleteTeamDialog) {
                        Button("Delete", role: .destructive) { adminDashboardViewModel.deleteTeam()}
                        Button("Cancel", role: .cancel) { adminDashboardViewModel.isDeleteTeamDialog.toggle() }
                    } message: {
                        Text("Are you sure you want to delete the Team? This action cannot be undone.")
                    }
            }
        }
        .listBackground()
        .sheet(isPresented: $adminDashboardViewModel.isAddAdminSheet) {
            List {
                if adminDashboardViewModel.teamTrainer.isEmpty {
                    NoTeamMemberAvaible()
                } else {
                    ForEach(adminDashboardViewModel.teamTrainer) { trainer in
                        Label(trainer.userProfile.fullName, systemImage: "plus")
                            .onTapGesture {
                                adminDashboardViewModel.addTrainerToAdmin(trainer: trainer)
                            }
                    }
                }
            }
        }
        .background(Theme.background)
        .navigationTitle("Admindashboard")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Text("Save")
                    .onTapGesture {
                        adminDashboardViewModel.save()
                    }
            }
        }
    }
}

@MainActor @Observable class AdminDashboardViewModel {
    let repository: BaseRepository = Repository.shared
    let errorHandler: ErrorHandlerViewModel = ErrorHandlerViewModel.shared
    let messagehandler: InAppMessagehandlerViewModel = InAppMessagehandlerViewModel.shared
    
    let userId: UUID?
    let currentTeam: Team?
    let currentAccount: UserAccount?
    
    var teamName = ""
    var isDeleteTeamDialog = false
    var isAddAdminSheet = false
    
    var teamAdmin: [TeamAdminProfile] = []
    var teamTrainer: [TeamMemberProfile] = []
    
    init(userId: UUID?, currentAccount: UserAccount?, currentTeam: Team?) {
        self.currentTeam = currentTeam
        self.currentAccount = currentAccount
        self.userId = userId
        
        self.getAllTeamAdmins()
        self.getAllTeamMemberAvaibleToBeAdmin()
        self.setTeamName()
    }
    
    func deleteTeam() {
        Task {
            do {
                guard let currentTeam = currentTeam else { throw TeamError.teamNotFound }
                guard let userId = currentAccount?.userId else { throw UserError.userIdNotFound }
                
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
        guard let userId = userId else { return }
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
            guard let userId = userId else { return }
            try repository.teamRepository.softDelete(teamAdmin: admin, userId: userId)
        } catch {
            errorHandler.handleError(error: error)
        }
    }
}
