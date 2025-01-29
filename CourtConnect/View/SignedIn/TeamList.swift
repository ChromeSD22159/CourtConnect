//
//  TeamList.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 29.01.25.
//
import SwiftUI

struct TeamList: View {
    @State var teamViewModel: TeamListViewModel
    
    init(repository: Repository) {
        teamViewModel = TeamListViewModel(repository: repository)
    }
    
    var body: some View {
        List {
            Section {
                Text("Teams: \(teamViewModel.foundTeams.count)")
            }
            
            ForEach(teamViewModel.foundTeams, id: \.id) { team in
                Section {
                    if teamViewModel.foundTeams.isEmpty {
                        Text("Kein Team gefunden!")
                    } else {
                        HStack {
                            Text(team.teamName)
                            
                            Button(action: {
                                teamViewModel.selectedTeam = team
                                teamViewModel.showJoinTeamAlert = true
                            }) {
                                Image(systemName: "person.badge.plus")
                            }
                        }
                    }
                }
            }
        }
        .searchable(text: $teamViewModel.searchTeamName, isPresented: $teamViewModel.isSearchBar)
        .onSubmit(of: .search) {
            guard !teamViewModel.searchTeamName.isEmpty else { return }
            teamViewModel.searchTeam()
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0 , execute: {
                teamViewModel.isSearchBar.toggle()
            })
        }
        .alert("Dem Team beitreten?", isPresented: $teamViewModel.showJoinTeamAlert) {
                    Button("Beitreten", role: .destructive) { }
                    Button("Abbrechen", role: .cancel) { }
                } message: {
                    Text("Möchtest du dem Team \(teamViewModel.selectedTeam?.teamName ?? "") beitreten?")
                }
    }
} 
