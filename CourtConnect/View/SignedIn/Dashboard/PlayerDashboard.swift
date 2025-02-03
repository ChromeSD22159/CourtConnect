//
//  PlayerDashboard.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 27.01.25.
//
import SwiftUI

@Observable class PlayerDashboardViewModel {
    
}

struct PlayerDashboard: View {
    @ObservedObject var userViewModel: SharedUserViewModel
    @ObservedObject var dashBoardViewModel: DashBoardViewModel
    
    @State var teamListViewModel: TeamListViewModel
    @State var isEnterCode = false
    
    init(userViewModel: SharedUserViewModel, dashBoardViewModel: DashBoardViewModel) {
        self.userViewModel = userViewModel
        self.dashBoardViewModel = dashBoardViewModel
        self.teamListViewModel = TeamListViewModel(repository: userViewModel.repository)
    }
    
    var body: some View {
        VStack {
            Text(userViewModel.userProfile?.firstName ?? "")
            Text(userViewModel.currentAccount?.role ?? "")
           
            // MARK: IF HAS TEAM
            if let team = dashBoardViewModel.currentTeam {
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
                
            } else {
                // MARK: IF HAS NO TEAM
                NavigationLink {
                    SearchTeam(teamListViewModel: teamListViewModel, userViewModel: userViewModel)
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
              
            ConfirmButtonLabel(confirmButtonDialog: ConfirmButtonDialog(
                systemImage: "trash",
                buttonText: "Delete Player Account",
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
            dashBoardViewModel.currentTeam = nil
            dashBoardViewModel.getTeam(for: userViewModel.currentAccount)
        }
        .navigationTitle("Spieler")
    }
} 

#Preview {
    @Previewable @State var dashBoardViewModel = DashBoardViewModel(repository: RepositoryPreview.shared)
    @Previewable @State var userViewModel = SharedUserViewModel(repository: RepositoryPreview.shared)
    
    ZStack {
        NavigationStack {
            PlayerDashboard(userViewModel: userViewModel, dashBoardViewModel: dashBoardViewModel)
        }
        .navigationStackTint()
        .previewEnvirments()
    }
    .onAppear {
        userViewModel.currentAccount = MockUser.myUserAccount
        dashBoardViewModel.currentTeam = Team(teamName: "Bulls", headcoach: "", joinCode: "", email: "", createdByUserAccountId: MockUser.myUserAccount.id, createdAt: Date(), updatedAt: Date())
      
    }
}
