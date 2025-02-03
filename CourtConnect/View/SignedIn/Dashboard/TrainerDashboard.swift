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
            if let currentTeam = dashBoardViewModel.currentTeam {
                HasTeam(userViewModel: userViewModel, dashBoardViewModel: dashBoardViewModel, teamId: currentTeam.id)
            } else {
                HasNoTeam(
                    userViewModel: userViewModel,
                    dashBoardViewModel: dashBoardViewModel,
                    foundNewTeamViewModel: foundNewTeamViewModel,
                    teamListViewModel: teamListViewModel
                )
            } 
            
            ConfirmButtonLabel(confirmButtonDialog: ConfirmButtonDialog(
                systemImage: "trash",
                buttonText: "Delete Trainer Account",
                question: "Delete your Account",
                message: "Are you sure you want to delete your account? This action cannot be undone.",
                action: "Delete",
                cancel: "Cancel"
            ), action: {
                Task {
                    do {
                        try await dashBoardViewModel.deleteUserAccount(for: userViewModel.currentAccount)
                        try userViewModel.setRandomAccount()
                    } catch {
                        print(error)
                    }
                }
            })
        }
        .onAppear {
            dashBoardViewModel.getTeam(for: userViewModel.currentAccount)
        }
        .navigationTitle("Trainer")
    }
}

fileprivate struct HasNoTeam: View {
    @ObservedObject var userViewModel: SharedUserViewModel
    @ObservedObject var dashBoardViewModel: DashBoardViewModel
    @ObservedObject var foundNewTeamViewModel: FoundNewTeamViewModel
    @ObservedObject var teamListViewModel: TeamListViewModel
    
    @State var isEnterCode = false
    
    var body: some View {
        VStack {
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
       
    }
}

fileprivate struct HasTeam: View {
    @ObservedObject var userViewModel: SharedUserViewModel
    @ObservedObject var dashBoardViewModel: DashBoardViewModel
    let teamId: UUID
    
    var body: some View {
        VStack {
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
            
            if let userAccount = userViewModel.currentAccount {
                DocumentSheetButton(userAccount: userAccount) 
                
                PlanTerminSheetButton(userAccount: userAccount) { termin in
                    dashBoardViewModel.saveTermin(termin: termin)
                }
            }
              
            if let QRCode = dashBoardViewModel.qrCode {
                ShowTeamJoinQrCode(QRCode: QRCode)
            }
            
            ConfirmButtonLabel(confirmButtonDialog: ConfirmButtonDialog(
                systemImage: "iphone.and.arrow.right.inward",
                buttonText: "Leave Team",
                question: "Want Leave the Team",
                message: "Are you sure you want to leave the Team? This action cannot be undone.",
                action: "Delete",
                cancel: "Cancel"
            ), action: {
                do {
                    try dashBoardViewModel.leaveTeam(for: userViewModel.currentAccount)
                } catch {
                    print(error)
                }
            })
        }
        
    }
}

fileprivate struct GenerateNewJoinCodeView: View {
    @State var isGenerateCode = false
    var body: some View {
        RowLabelButton(text: "Generate new joinCode", systemImage: "qrcode.viewfinder") {
            isGenerateCode.toggle()
        }
        .sheet(isPresented: $isGenerateCode, content: {
            ZStack {
                Theme.background.ignoresSafeArea()
                
                GenerateCodeViewSheet()
            }
        })
    }
}

fileprivate struct ShowTeamJoinQrCode: View {
    var QRCode: UIImage
    @State var showQrSheet = false
    var body: some View {
        RowLabelButton(text: "Show Join QR Code", systemImage: "qrcode.viewfinder") {
            showQrSheet.toggle()
        }
        .sheet(isPresented: $showQrSheet, onDismiss: {}) {
            SheetStlye(title: "Join QR Code", detents: [.medium], isLoading: .constant(false)) {
                Image(uiImage: QRCode)
                    .resizable()
                    .interpolation(.none)
                    .scaledToFit()
                    .frame(width: 300, height: 300)
            }
        }
    }
}
 
#Preview {
    @Previewable @State var dashBoardViewModel = DashBoardViewModel(repository: RepositoryPreview.shared)
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

#Preview {
    SnapScrollView(horizontalSpacing: 0) {
        ForEach(0..<10, id: \.self) { _ in
            RoundedIconTextCard(icon: "person.crop.circle.badge.plus", title: "Found team now!", description: "Start your own team and manage players and training sessions.")
        }
    }
}
