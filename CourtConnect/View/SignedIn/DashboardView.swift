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
    @State var networkMonitorViewModel: NetworkMonitorViewModel = NetworkMonitorViewModel.shared
    
    @State var inAppMessagehandler = InAppMessagehandler.shared
    
    var body: some View {
        NavigationStack {
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
            .navigationTitle("Dashboard")
            .navigationBarTitleDisplayMode(.inline)
            .userToolBar(userViewModel: userViewModel, userAccountViewModel: userAccountViewModel)
        } 
    }
}
 
#Preview {
    @Previewable @State var userViewModel = SharedUserViewModel(repository: Repository(type: .preview))
    @Previewable @State var userAccountViewModel = UserAccountViewModel(repository: Repository(type: .preview), userId: nil)
    @Previewable @State var networkMonitorViewModel = NetworkMonitorViewModel.shared
    
    DashboardView(
        userViewModel: userViewModel,
        userAccountViewModel: userAccountViewModel,
        networkMonitorViewModel: networkMonitorViewModel
    ) 
    .messagePopover()
}
