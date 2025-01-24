//
//  DashboardView.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 16.01.25.
//
import SwiftUI 
import FirebaseAuth
struct DashboardView: View {
    @ObservedObject var userViewModel: SharedUserViewModel
    @ObservedObject var userAccountViewModel: UserAccountViewModel
    @ObservedObject var networkMonitorViewModel: NetworkMonitorViewModel
    
    @State var inAppMessagehandler = InAppMessagehandler.shared
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                if !networkMonitorViewModel.isConnected {
                    InternetUnavailableView()
                } else {
                    if let currentAccount = userViewModel.currentAccount {
                        Button(currentAccount.role) {
                            userAccountViewModel.deleteUserAccount(userAccount: currentAccount)
                            
                            userAccountViewModel.sendUpdatedAfterLastSyncToBackend()
                            
                            userViewModel.setCurrentAccount(newAccount: nil)
                        }
                    } 
                }
            } 
            .navigationTitle("Daskboard")
            .navigationBarTitleDisplayMode(.inline)
            .userToolBar(userViewModel: userViewModel, userAccountViewModel: userAccountViewModel)
            .onAppear {
                userViewModel.onAppDashboardAppear()
            }
        } 
    }
}
 
#Preview {
    @Previewable @State var userViewModel = SharedUserViewModel(repository: Repository(type: .preview))
    @Previewable @State var userAccountViewModel = UserAccountViewModel(repository: Repository(type: .preview), userId: "nil")
    @Previewable @State var networkMonitorViewModel = NetworkMonitorViewModel()
    
    DashboardView(
        userViewModel: userViewModel,
        userAccountViewModel: userAccountViewModel,
        networkMonitorViewModel: networkMonitorViewModel
    ) 
    .messagePopover()
}
