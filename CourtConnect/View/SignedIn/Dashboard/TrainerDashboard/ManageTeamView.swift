//
//  ManageTeamView.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 06.02.25.
//
import SwiftUI
 
struct ManageTeamView: View {
    var viewModel: ManageTeamViewModel = ManageTeamViewModel()
    
    var body: some View {
        AnimationBackgroundChange {
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
                                        viewModel.kickMember()
                                    } label: {
                                        Label("Remove", systemImage: "trash.fill")
                                    }
                                }
                        }
                    }
                } header: {
                    UpperCasedheadline(text: "Player")
                }.blurrylistRowBackground()
                
                Section {
                    if viewModel.teamTrainer.isEmpty {
                        NoTeamTrainerAvaible()
                    } else {
                        ForEach(viewModel.teamTrainer, id: \.userProfile.id) { team in
                            MemberRow(teamMember: team.teamMember, userProfile: team.userProfile, isPlayer: false)
                            .swipeActions {
                                Button(role: .destructive) {
                                    Task {
                                        do {
                                            team.teamMember.deletedAt = Date()
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
                }.blurrylistRowBackground()
            }
        }
        .listBackgroundAnimated()
        .onAppear {
            viewModel.inizialize() 
        }
    }
}

fileprivate struct MemberRow: View {
    @Bindable var teamMember: TeamMember
    var userProfile: UserProfile
    var isPlayer: Bool
    var body: some View {
        VStack(alignment: .leading) {
            Text(userProfile.fullName)
            Spacer()
            HStack {
                if isPlayer {
                    Picker("Position:", selection: $teamMember.position) {
                        if teamMember.position == "" {
                            Text("Please choose").tag("")
                        }
                        
                        ForEach(BasketballPosition.allCases, id: \.id) { position in
                            Text("\(position.rawValue)").tag(position.rawValue)
                        }
                    }
                    .labelsHidden()
                    .pickerStyle(.menu)
                    .onChange(of: teamMember.position) {
                        Task {
                            do {
                                try await SupabaseService.upsertWithOutResult(item: teamMember.toDTO(), table: .teamMember, onConflict: "id")
                            } catch {
                                print(error)
                            }
                        }
                    }
                    Spacer()
                    let shirtNumberOptions = (0...99).map { ShirtNumberOption(number: $0) }
                    Picker("Shirt Number", selection: $teamMember.shirtNumber) {
                        if teamMember.shirtNumber == nil {
                            Text("Please choose").tag(nil as Int?)
                        }
                       
                        ForEach(shirtNumberOptions) { option in
                                Text("\(option.number)").tag(option.number)
                        }
                    }
                    .labelsHidden()
                    .pickerStyle(.menu)
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
        .listBackgroundAnimated()
    }
} 

#Preview {
    ManageTeamView()
}
