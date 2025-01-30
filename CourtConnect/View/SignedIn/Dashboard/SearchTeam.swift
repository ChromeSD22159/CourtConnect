//
//  SearchTeam.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 29.01.25.
//
import SwiftUI

struct SearchTeam: View {
    @ObservedObject var teamListViewModel: TeamListViewModel
    
    var body: some View {
        List {
            Section {
                Text("Teams: \(teamListViewModel.foundTeams.count)")
            }
            
            ForEach(teamListViewModel.foundTeams, id: \.id) { team in
                Section {
                    if teamListViewModel.foundTeams.isEmpty {
                        Text("Kein Team gefunden!")
                    } else {
                        HStack {
                            Text(team.teamName)
                            
                            Button(action: {
                                teamListViewModel.selectedTeam = team
                                teamListViewModel.showJoinTeamAlert = true
                            }) {
                                Image(systemName: "person.badge.plus")
                            }
                        }
                    }
                }
            }
            
        }
        .contentMargins(.top, 20)
        .listBackground()
        .searchable(text: $teamListViewModel.searchTeamName, isPresented: $teamListViewModel.isSearchBar)
        .onSubmit(of: .search) {
            guard !teamListViewModel.searchTeamName.isEmpty else { return }
            teamListViewModel.searchTeam()
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0 , execute: {
                teamListViewModel.isSearchBar.toggle()
            })
        }
        .alert("Dem Team beitreten?", isPresented: $teamListViewModel.showJoinTeamAlert) {
                    Button("Beitreten", role: .destructive) { }
                    Button("Abbrechen", role: .cancel) { }
                } message: {
                    Text("Möchtest du dem Team \(teamListViewModel.selectedTeam?.teamName ?? "") beitreten?")
                }
    }
} 

#Preview {
    SearchTeam(teamListViewModel: TeamListViewModel(repository: RepositoryPreview.shared))
        .previewEnvirments()
}
