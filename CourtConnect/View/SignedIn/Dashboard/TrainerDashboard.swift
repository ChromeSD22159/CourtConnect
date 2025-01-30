//
//  TrainerDashboard.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 27.01.25.
//
import SwiftUI

struct TrainerDashboard: View {
    @ObservedObject var userViewModel: SharedUserViewModel
    @ObservedObject var dashBoardViewModel: DashBoardViewModel
    
    @State var isGenerateCode = false
    @State var isEnterCode = false
    
    @State var foundNewTeamViewModel: FoundNewTeamViewModel
    @State var teamListViewModel: TeamListViewModel
    
    init(userViewModel: SharedUserViewModel, dashBoardViewModel: DashBoardViewModel) {
        self.userViewModel = userViewModel 
        self.dashBoardViewModel = dashBoardViewModel
        self.foundNewTeamViewModel = FoundNewTeamViewModel(repository: userViewModel.repository)
        self.teamListViewModel = TeamListViewModel(repository: userViewModel.repository)
    }
    
    var body: some View {
        VStack(spacing: 15) {
            if dashBoardViewModel.currentTeam != nil {
                hasNoTeam()
            } else {
                hasTeam()
            }
        }
        .onAppear {
            dashBoardViewModel.getTeam(for: userViewModel.currentAccount)
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
    
    @ViewBuilder func hasNoTeam() -> some View {
        Button("Leave Team") {
            do {
                try dashBoardViewModel.leaveTeam(for: userViewModel.currentAccount)
            } catch {
                print(error)
            }
        }
    }
    
    @ViewBuilder func hasTeam() -> some View {
        NavigationLink {
            if let userAccount = userViewModel.currentAccount, let userProfile = userViewModel.userProfile {
                FoundNewTeamView(viewModel: foundNewTeamViewModel, userAccount: userAccount, userProfile: userProfile)
            }
        } label: {
            Card(icon: "person.crop.circle.badge.plus", title: "Found team now!", description: "Start your own team and manage players and training sessions.")
        }
        
        NavigationLink {
            SearchTeam(teamListViewModel: teamListViewModel)
        } label: {
            Card(icon: "person.badge.plus", title: "Join a Team!", description: "Send a request to join a team as a trainer and start managing players and training sessions.")
        }
             
        Card(icon: "qrcode.viewfinder", title: "Join with Team ID!", description: "Enter a Team ID to instantly join an existing team and start managing players and training sessions.")
            .onTapGesture {
                isEnterCode.toggle()
            }
        
        Button("Generate Code Neu") {
            isGenerateCode.toggle()
        }
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
                .background(Theme.headline)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            
            VStack(alignment: .leading) {
                Text(title)
                    .multilineTextAlignment(.leading)
                    .foregroundStyle(Theme.headline)
                
                Text(description)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2, reservesSpace: true)
                    .font(.caption)
                    .foregroundStyle(Theme.text)
            }
         
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Material.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .padding(.horizontal)
    }
}

#Preview {
    NavigationStack {
        VStack(spacing: 15) {
            
            Card(icon: "person.crop.circle.badge.plus", title: "Found team now!", description: "Start your own team and manage players and training sessions.")
            
            NavigationLink {
                SearchTeam(teamListViewModel: TeamListViewModel(repository: RepositoryPreview.shared))
            } label: {
                Card(icon: "person.badge.plus", title: "Join a Team!", description: "Send a request to join a team as a trainer and start managing players and training sessions.")
            }
            
            Card(icon: "qrcode.viewfinder", title: "Join with Team ID!", description: "Enter a Team ID to instantly join an existing team and start managing players and training sessions.")
        }
    }
    .previewEnvirments()
    .navigationStackTint()
}
