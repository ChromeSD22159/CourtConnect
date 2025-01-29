//
//  DashboardView.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 16.01.25.
//
import SwiftUI 

struct DashboardView: View {
    @ObservedObject var userViewModel: SharedUserViewModel
    @ObservedObject var userAccountViewModel: UserAccountViewModel
    @Environment(SyncServiceViewModel.self) private var syncServiceViewModel
    @Environment(\.messagehandler) var messagehandler
    @Environment(\.errorHandler) var errorHanler
    @Environment(\.networkMonitor) var networkMonitor
    
    var body: some View {
        ScrollView(.vertical) {
            InternetUnavailableView()
            
            if let currentAccount = userViewModel.currentAccount, let role = UserRole(rawValue: currentAccount.role) {
                switch role {
                case .player: PlayerDashboard(userViewModel: userViewModel, userAccountViewModel: userAccountViewModel)
                case .trainer: TrainerDashboard(userViewModel: userViewModel, userAccountViewModel: userAccountViewModel)
                case .admin: EmptyView()
                }
            }
        }
        .contentMargins(.top, 20)
        .errorPopover()
        .navigationTitle("Dashboard")
        .navigationBarTitleDisplayMode(.inline)
        .userToolBar(userViewModel: userViewModel, userAccountViewModel: userAccountViewModel)
        .fullScreenCover(
            isPresented: $userViewModel.showOnBoarding,
            onDismiss: { sync() },
            content: {
                if let userProfile = userViewModel.userProfile {
                    OnBoardingView(firstName: userProfile.firstName)
                }
            }
        )
    }
    
    func sync() {
        userViewModel.onDismissOnBoarding(onComplete: { userId, error in
            if let error = error {
                errorHanler.handleError(error: error) 
            }
            if let userId = userId {
                Task {
                    try await syncServiceViewModel.sendAllData(userId: userId)
                }
            }
        })
    }
}
 
#Preview { 
    @Previewable @State var userViewModel = SharedUserViewModel(repository: Repository(type: .preview)) 
    @Previewable @State var userAccountViewModel = UserAccountViewModel(repository: Repository(type: .preview), userId: nil)
    @Previewable @State var networkMonitorViewModel = NetworkMonitorViewModel.shared
    
    NavigationStack {
        DashboardView(
            userViewModel: userViewModel,
            userAccountViewModel: userAccountViewModel
        )
        .messagePopover()
    }
    .environment(SyncServiceViewModel(repository: Repository(type: .preview)))
}
