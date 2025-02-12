//
//  PlayerDashboard.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 27.01.25.
//
import SwiftUI 
 
struct PlayerDashboard: View {
    @Environment(\.scenePhase) var scenePhase
    @State var playerDashboardViewModel = PlayerDashboardViewModel()
    var body: some View {
        VStack {
            if playerDashboardViewModel.currentTeam != nil {
                HasTeam(playerDashboardViewModel: playerDashboardViewModel)
            } else {
                HasNoTeam(playerDashboardViewModel: playerDashboardViewModel)
                    .padding(.bottom, 40)
            }
              
            ConfirmButtonLabel(confirmButtonDialog: ConfirmButtonDialog(
                systemImage: "trash",
                buttonText: "Delete Player Account",
                question: "Delete your Account",
                message: "Are you sure you want to delete your account? This action cannot be undone.",
                action: "Delete",
                cancel: "Cancel"
            ), material: .ultraThinMaterial) {
                 playerDashboardViewModel.deleteUserAccount()
            }
        }
        .reFetchButton(isFetching: $playerDashboardViewModel.isfetching, onTap: {
            playerDashboardViewModel.fetchDataFromRemote()
        }) 
        .padding(.horizontal, 16)
        .padding(.top, 10)
        .onAppear {
            playerDashboardViewModel.inizialize()
        }
        .onChange(of: scenePhase) {  
            if scenePhase == .active {
                playerDashboardViewModel.fetchDataFromRemote()
            }
        }
        .navigationTitle("Player Dashboard")
    }
} 
 
fileprivate struct HasNoTeam: View {
    @Bindable var playerDashboardViewModel: PlayerDashboardViewModel
    var body: some View {
        NavigationLink {
            SearchTeam()
        } label: {
            RoundedIconTextCard(icon: "person.badge.plus", title: "Join a Team!", description: "Send a request to join a team as a trainer and start managing players and training sessions.")
        }
        
        RoundedIconTextCard(icon: "qrcode.viewfinder", title: "Join with Team ID!", description: "Enter a Team ID to instantly join an existing team and start managing players and training sessions.")
            .onTapGesture {
                playerDashboardViewModel.isEnterCode.toggle()
            }
            .sheet(isPresented: $playerDashboardViewModel.isEnterCode, onDismiss: {
                playerDashboardViewModel.getTeam()
            }) {
                if let currentAccount = playerDashboardViewModel.userAccount {
                    ZStack {
                        Theme.backgroundGradient.ignoresSafeArea()
                        
                        EnterCodeView(userAccount: currentAccount)
                    }
                }
            }
    }
}

fileprivate struct HasTeam: View {
    var playerDashboardViewModel: PlayerDashboardViewModel
    
    var body: some View {
        AbsenseCard(playerDashboardViewModel: playerDashboardViewModel) {
            playerDashboardViewModel.absenceRegister()
        }
           
        CalendarCard(termine: playerDashboardViewModel.termine, editable: false)
            .padding(.vertical)
        
        ConfirmationTermin(attendanceTermines: playerDashboardViewModel.attendancesTermines) { attendance in
            playerDashboardViewModel.updateTerminAttendance(attendance: attendance)
        }
        
        ConfirmButtonLabel(confirmButtonDialog: ConfirmButtonDialog(
                systemImage: "iphone.and.arrow.right.inward",
                buttonText: "Leave Team",
                question: "Want Leave the Team",
                message: "Are you sure you want to leave the Team? This action cannot be undone.",
                action: "Leave",
                cancel: "Cancel"
            ), material: .ultraThinMaterial
        ) {
            playerDashboardViewModel.leaveTeam(role: .player)
        }
        .padding(.top, 40)
    }
}

#Preview {
    ZStack {
        NavigationStack {
            PlayerDashboard()
        }
        .navigationStackTint()
    }
}

#Preview {
    ZStack {}
        .sheet(isPresented: .constant(true)) {
            NavigationStack {
                VStack {
                    DatePicker("Absense Date", selection: .constant(Date()), displayedComponents: .date) 
                }
                .padding() 
                .navigationTitle(title: "Absense")
            }
            .navigationStackTint()
            .presentationDetents([.height(150)])
            .presentationBackground(Material.ultraThinMaterial)
            .presentationCornerRadius(20)
        }
}
