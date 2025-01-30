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
                hasTeam(teamId: dashBoardViewModel.currentTeam!.id)
            } else {
                hasNoTeam()
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
        .sheet(isPresented: $isEnterCode, onDismiss: {
            dashBoardViewModel.getTeam(for: userViewModel.currentAccount)
        }) {
            if let currentAccount = userViewModel.currentAccount {
                ZStack {
                    Theme.background.ignoresSafeArea()
                    
                    EnterCodeView(userAccount: currentAccount)
                }
            }
        }
    }
    
    @ViewBuilder func hasNoTeam() -> some View {
        NavigationLink {
            if let userAccount = userViewModel.currentAccount, let userProfile = userViewModel.userProfile {
                FoundNewTeamView(viewModel: foundNewTeamViewModel, userAccount: userAccount, userProfile: userProfile)
            }
        } label: {
            RoundedIconTextCard(icon: "person.crop.circle.badge.plus", title: "Found team now!", description: "Start your own team and manage players and training sessions.")
        }
        
        NavigationLink {
            SearchTeam(teamListViewModel: teamListViewModel)
        } label: {
            RoundedIconTextCard(icon: "person.badge.plus", title: "Join a Team!", description: "Send a request to join a team as a trainer and start managing players and training sessions.")
        }
        
        RoundedIconTextCard(icon: "qrcode.viewfinder", title: "Join with Team ID!", description: "Enter a Team ID to instantly join an existing team and start managing players and training sessions.")
            .onTapGesture {
                isEnterCode.toggle()
            }
    }
    
    @ViewBuilder func hasTeam(teamId: UUID) -> some View {
        SnapScrollView(horizontalSpacing: 16) {
            LazyHStack(spacing: 16) {
                NavigationLink {
                    TeamRequestsView(teamId: teamId)
                } label: {
                    IconCard(systemName: "person.fill.questionmark", title: "Join Requests", background: Material.ultraThinMaterial)
                }
            }
            .frame(height: 150)
        }
         
        Button("Generate Code Neu") {
            isGenerateCode.toggle()
        }
        
        Button("Leave Team") {
            do {
                try dashBoardViewModel.leaveTeam(for: userViewModel.currentAccount) 
            } catch {
                print(error)
            }
        }
    }
}  

#Preview {
    NavigationStack {
        VStack(spacing: 15) {
             
            SnapScrollView(horizontalSpacing: 16) {
                LazyHStack(spacing: 16) {
                    NavigationLink {
                        TeamRequestsView(teamId: UUID(uuidString: "99580a57-81dc-4f4d-adde-0e871505c679")!)
                    } label: {
                        IconCard(systemName: "person.fill.questionmark", title: "Join Requests", background: Material.ultraThinMaterial)
                    }
     
                    IconCard(systemName: "person.fill.questionmark", title: "Team Members", background: Theme.headline)
                    
                    IconCard(systemName: "person.fill.questionmark", title: "Team Document", background: Material.ultraThinMaterial)
                }
                .frame(height: 150)
            }
             
            RoundedIconTextCard(icon: "person.crop.circle.badge.plus", title: "Found team now!", description: "Start your own team and manage players and training sessions.")
            
            NavigationLink {
                SearchTeam(teamListViewModel: TeamListViewModel(repository: RepositoryPreview.shared))
            } label: {
                RoundedIconTextCard(icon: "person.badge.plus", title: "Join a Team!", description: "Send a request to join a team as a trainer and start managing players and training sessions.")
            }
            
            RoundedIconTextCard(icon: "qrcode.viewfinder", title: "Join with Team ID!", description: "Enter a Team ID to instantly join an existing team and start managing players and training sessions.")
        }
    }
    .previewEnvirments()
    .navigationStackTint()
}
 
struct SnapScrollView<Content: View>: View {
    @ViewBuilder var content: () -> Content
    let horizontalSpacing: CGFloat
    
    init(horizontalSpacing: CGFloat = 16, content: @escaping () -> Content) {
        self.content = content
        self.horizontalSpacing = horizontalSpacing
    }
    
    var body: some View {
        VStack {
            ScrollView(.horizontal) {
                content()
                    .scrollTargetLayout()
            }
            .scrollTargetBehavior(.viewAligned)
            .safeAreaPadding(.horizontal, horizontalSpacing)
            .scrollIndicators(.hidden)
        }
    }
    
    func calculateCurrentIndex(from xValue: CGFloat, contentWidth: CGFloat) -> Int {
        let pageWidth = contentWidth // Width of each page/item, including spacing
        let currentPage = Int(round(-xValue / pageWidth))
        return currentPage
    }
}

#Preview {
    SnapScrollView(horizontalSpacing: 0) {
        ForEach(0..<10, id: \.self) { _ in
            RoundedIconTextCard(icon: "person.crop.circle.badge.plus", title: "Found team now!", description: "Start your own team and manage players and training sessions.")
        }
    }
}
