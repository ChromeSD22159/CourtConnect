//
//  TrainerDashboard.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 27.01.25.
//
import SwiftUI

struct TrainerDashboard: View {
    @ObservedObject var userViewModel: SharedUserViewModel
    @ObservedObject var userAccountViewModel: UserAccountViewModel
    @State var teamViewModel: TeamViewModel
    @State var isGenerateCode = false
    @State var isEnterCode = false
    
    init(userViewModel: SharedUserViewModel, userAccountViewModel: UserAccountViewModel) {
        self.userViewModel = userViewModel
        self.userAccountViewModel = userAccountViewModel
        self.teamViewModel = TeamViewModel(repository: userViewModel.repository)
    }
    
    var body: some View {
        VStack(spacing: 15) {
            Card(icon: "person.crop.circle.badge.plus", title: "Found team now!", description: "Start your own team and manage players and training sessions.")
            
            NavigationLink {
                TeamList(repository: userViewModel.repository)
            } label: {
                Card(icon: "person.badge.plus", title: "Join a Team!", description: "Send a request to join a team as a trainer and start managing players and training sessions.")
            }
                 
            Card(icon: "qrcode.viewfinder", title: "Join with Team ID!", description: "Enter a Team ID to instantly join an existing team and start managing players and training sessions.").onTapGesture {
                isEnterCode.toggle()
            }
            
            Button("Generate Code") {
                isGenerateCode.toggle()
            }
        }
        .navigationTitle("Trainer")
        .sheet(isPresented: $isGenerateCode, content: {
            ZStack {
                Theme.background.ignoresSafeArea()
                
                GenerateCodeView()
            }
        })
        .sheet(isPresented: $isEnterCode, content: {
            ZStack {
                Theme.background.ignoresSafeArea()
                
                EnterCodeView()
            }
        })
    }
}

private struct Card: View {
    let icon: String
    let title: String
    let description: String
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.largeTitle)
                .padding(10)
                .background(Theme.darkOrange)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            
            VStack(alignment: .leading) {
                Text(title)
                
                Text(description)
                    .lineLimit(2, reservesSpace: true)
                    .font(.caption)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Material.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .padding(.horizontal)
    }
}

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

@MainActor
@Observable class TeamListViewModel {
    var showJoinTeamAlert: Bool = false
    var searchTeamName: String = ""
    var isSearchBar: Bool  = false
    var foundTeams: [TeamDTO] = []
    var selectedTeam: TeamDTO?
    
    let repository: Repository
    
    init(repository: Repository) {
        self.repository = repository
    }
    
    func searchTeam() {
        Task {
            do {
                foundTeams = try await repository.teamRepository.searchTeamByName(name: searchTeamName)
                print(foundTeams.count)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func resetFoundTeams() {
        foundTeams = []
    }
    
    func joinTeam(team: TeamDTO) {
    }
}

#Preview {
    NavigationStack {
        VStack(spacing: 15) {
            
            Card(icon: "person.crop.circle.badge.plus", title: "Found team now!", description: "Start your own team and manage players and training sessions.")
            
            NavigationLink {
                TeamList(repository: Repository(type: .preview))
            } label: {
                Card(icon: "person.badge.plus", title: "Join a Team!", description: "Send a request to join a team as a trainer and start managing players and training sessions.")
            }
            
            Card(icon: "qrcode.viewfinder", title: "Join with Team ID!", description: "Enter a Team ID to instantly join an existing team and start managing players and training sessions.")
        }
    }
}
