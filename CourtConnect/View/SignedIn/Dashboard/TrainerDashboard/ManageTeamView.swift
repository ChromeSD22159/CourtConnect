//
//  ManageTeamView.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 06.02.25.
//
import SwiftUI

struct ManageTeamView: View {
    var viewModel: ManageTeamViewModel
    
    init(teamId: UUID) {
        self.viewModel = ManageTeamViewModel(repository: Repository.shared, teamId: teamId)
    }
    
    var body: some View {
        List {
            Section {
                ForEach(viewModel.teamPlayer, id: \.userProfile.id) { team in
                    MemberRow(teamMember: team.teamMember, userProfile: team.userProfile, isPlayer: true)
                        .swipeActions {
                            Button(role: .destructive) {
                                // TODO
                            } label: {
                                Label("Remove", systemImage: "trash.fill")
                            }
                        }
                }
            } header: {
                HStack {
                    UpperCasedheadline(text: "Player")
                    Spacer()
                }
                .padding(.horizontal)
            }
            
            Section {
                ForEach(viewModel.teamTrainer, id: \.userProfile.id) { team in
                    MemberRow(teamMember: team.teamMember, userProfile: team.userProfile, isPlayer: false)
                        .swipeActions {
                            Button(role: .destructive) {
                                // TODO
                            } label: {
                                Label("Remove", systemImage: "trash.fill")
                            }
                        }
                }
            } header: {
                HStack {
                    UpperCasedheadline(text: "Trainer")
                    Spacer()
                }
                .padding(.horizontal)
            }
        }
        .listBackground()
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    
                }
            }
        }
    }
}

fileprivate struct MemberRow: View {
    @Bindable var teamMember: TeamMember
    var userProfile: UserProfile
    var isPlayer: Bool
    var body: some View {
        HStack {
            Text(userProfile.fullName)
            Spacer()
            if isPlayer {
                TextField("", text: Binding(
                    get: {
                        teamMember.shirtNumber == nil ? "" : String(teamMember.shirtNumber!)
                    },
                    set: { newValue in
                        if let intValue = Int(newValue) {
                             teamMember.shirtNumber = intValue
                             // Here you would likely want to also update the database
                             // viewModel.updateShirtNumber(for: teamMember, newShirtNumber: intValue)
                         } else if newValue.isEmpty {
                             teamMember.shirtNumber = nil
                             // viewModel.updateShirtNumber(for: teamMember, newShirtNumber: nil)
                         }
                    }
                ))
                .textFieldStyle(.plain)
                .padding(8)
                .background(Material.ultraThickMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .frame(width: 75)
            }
        }
    }
}

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
}

struct TeamMemberProfile {
    var userProfile: UserProfile
    var teamMember: TeamMember
}

#Preview {
    ManageTeamView(teamId: UUID())
}
