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
    @ObservedObject var syncServiceViewmodel: SyncServiceViewModel
    
    @State var networkMonitorViewModel: NetworkMonitorViewModel = NetworkMonitorViewModel.shared
    @State var errorHanler = ErrorHandlerViewModel.shared
    @State var inAppMessagehandler = InAppMessagehandler.shared
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    
                    InternetUnavailableView()
                    
                    if let currentAccount = userViewModel.currentAccount, let role = UserRole(rawValue: currentAccount.role) {
                        switch role {
                        case .player: PlayerDashboard(userViewModel: userViewModel, userAccountViewModel: userAccountViewModel)
                        case .trainer: TrainerDashboard(userViewModel: userViewModel, userAccountViewModel: userAccountViewModel)
                        case .admin: EmptyView()
                        }
                        
                        Button(currentAccount.role) {
                            userAccountViewModel.deleteUserAccount(userAccount: currentAccount)
                            
                            userAccountViewModel.sendUpdatedAfterLastSyncToBackend()
                            
                            userViewModel.setCurrentAccount(newAccount: nil)
                        }
                    } 
                    
                }
            }
            .errorPopover()
            .navigationTitle("Dashboard")
            .navigationBarTitleDisplayMode(.inline)
            .userToolBar(userViewModel: userViewModel, userAccountViewModel: userAccountViewModel)
            .fullScreenCover(
                isPresented: $userViewModel.showOnBoarding,
                onDismiss: {
                    Task {
                        do {
                            userViewModel.setOnBooarding()
                            guard let userId = userViewModel.user?.id else { throw UserError.userIdNotFound }
                            try await syncServiceViewmodel.sendAllData(userId: userId)
                        } catch {
                            errorHanler.handleError(error: error)
                        }
                    }
                },
                content: {
                    if let userProfile = userViewModel.userProfile {
                        OnBoardingView(firstName: userProfile.firstName)
                    }
                }
            )
        }
    }
}
 
#Preview { 
    @Previewable @State var userViewModel = SharedUserViewModel(repository: Repository(type: .preview))
    @Previewable @State var syncServiceViewmodel = SyncServiceViewModel(repository: Repository(type: .preview))
    @Previewable @State var userAccountViewModel = UserAccountViewModel(repository: Repository(type: .preview), userId: nil)
    @Previewable @State var networkMonitorViewModel = NetworkMonitorViewModel.shared
    
    DashboardView(
        userViewModel: userViewModel,
        userAccountViewModel: userAccountViewModel,
        syncServiceViewmodel: syncServiceViewmodel,
        networkMonitorViewModel: networkMonitorViewModel
    ) 
    .messagePopover()
}
