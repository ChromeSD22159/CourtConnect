//
//  SearchTeam.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 29.01.25.
//
import SwiftUI

struct SearchTeam: View {
    @ObservedObject var teamListViewModel: TeamListViewModel
    @ObservedObject var userViewModel: SharedUserViewModel
    @Environment(\.messagehandler) var messagehandler
    @Environment(\.errorHandler) var errorHandler
    var body: some View {
        List {
            Section {
                Text("Teams: \(teamListViewModel.foundTeams.count)")
            }
            
            ForEach(teamListViewModel.foundTeams, id: \.id) { team in
                Section {
                    if teamListViewModel.foundTeams.isEmpty {
                        Text("No team found!")
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
        .alert("Join Team?", isPresented: $teamListViewModel.showJoinTeamAlert) {
            Button("Join", role: .destructive) {
                Task { 
                    guard let userAccount = userViewModel.currentAccount else { return }
                    do {
                        try await teamListViewModel.requestTeam(userAccount: userAccount)
                        let msg = InAppMessage(title: "Request send!")
                        messagehandler.handleMessage(message: msg)
                    } catch {
                        errorHandler.handleError(error: error)
                    }
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Do you want to join the team \(teamListViewModel.selectedTeam?.teamName ?? "")?")
        }
    }
} 

#Preview {
    SearchTeam(teamListViewModel: TeamListViewModel(repository: RepositoryPreview.shared), userViewModel: SharedUserViewModel(repository: RepositoryPreview.shared))
        .previewEnvirments()
}
