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
            ListInfomationSection(text: "In this area you can assign an individual player number to every player in your team. Choose a number from the list for every player.")
            
            Section {
                if viewModel.teamPlayer.isEmpty {
                    NoTeamMemberAvaible()
                } else {
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
                }
            } header: {
                UpperCasedheadline(text: "Player")
            }
            
            Section {
                if viewModel.teamPlayer.isEmpty {
                    NoTeamTrainerAvaible()
                } else {
                    ForEach(viewModel.teamTrainer, id: \.userProfile.id) { team in
                        MemberRow(teamMember: team.teamMember, userProfile: team.userProfile, isPlayer: false)
                        .swipeActions {
                            Button(role: .destructive) {
                                Task {
                                    do {
                                        team.teamMember.deletedAt = Date()
                                        // TODO: DEBUG;
                                        try await SupabaseService.upsertWithOutResult(item: team.teamMember.toDTO(), table: .teamMember, onConflict: "id")
                                    } catch {
                                        print(error)
                                    }
                                }
                            } label: {
                                Label("Remove", systemImage: "trash.fill")
                            }
                        }
                    }
                }
            } header: {
                UpperCasedheadline(text: "Trainer")
            }
        }
        .listBackground()
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
                let shirtNumberOptions = (0...99).map { ShirtNumberOption(number: $0) }
                Picker("", selection: $teamMember.shirtNumber) {
                    if teamMember.shirtNumber == nil {
                        Text("Bitte Wählen").tag(nil as Int?)
                    } 
                   
                    ForEach(shirtNumberOptions) { option in
                            Text("\(option.number)").tag(option.number)
                    }
                }
                .onChange(of: teamMember.shirtNumber) {
                    Task {
                        do {
                            try await SupabaseService.upsertWithOutResult(item: teamMember.toDTO(), table: .teamMember, onConflict: "id")
                        } catch {
                            print(error)
                        }
                    }
                }
            }
        }
    }
} 

#Preview {
    ManageTeamView(teamId: UUID())
}
