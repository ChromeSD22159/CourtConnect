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
                UpperCasedheadline(text: "Player")
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
                UpperCasedheadline(text: "Trainer")
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
                let shirtNumberOptions = (0...99).map { ShirtNumberOption(number: $0) }
                Picker("", selection: $teamMember.shirtNumber) {
                    if teamMember.shirtNumber == nil {
                        Text("Bitte Wählen").tag(nil as Int?)
                    } 
                   
                    ForEach(shirtNumberOptions) { option in
                            Text("\(option.number)").tag(option.number)
                    }
                }
            }
        }
    }
} 

#Preview {
    ManageTeamView(teamId: UUID())
}
