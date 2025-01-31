//
//  DashboardView.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 16.01.25.
//
import SwiftUI 

struct DashboardView: View {
    @ObservedObject var userViewModel: SharedUserViewModel
    @Environment(SyncServiceViewModel.self) private var syncServiceViewModel
    @Environment(\.messagehandler) var messagehandler
    @Environment(\.errorHandler) var errorHanler
    @Environment(\.networkMonitor) var networkMonitor
    
    @State var dashBoardViewModel: DashBoardViewModel
    
    init(userViewModel: SharedUserViewModel) {
        self.userViewModel = userViewModel
        self.dashBoardViewModel = DashBoardViewModel(repository: userViewModel.repository)
    }
    
    var body: some View {
        ScrollView(.vertical) {
            if let currentAccount = userViewModel.currentAccount, let role = UserRole(rawValue: currentAccount.role) {
                switch role {
                case .player: PlayerDashboard(userViewModel: userViewModel)
                case .trainer: TrainerDashboard(userViewModel: userViewModel, dashBoardViewModel: dashBoardViewModel)
                case .admin: EmptyView()
                }
            }
        }
        .contentMargins(.top, 20)
        .errorPopover()
        .navigationTitle("Dashboard")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $userViewModel.isCreateRoleSheet, content: {
            CreateUserAccountView(userViewModel: userViewModel)
        })
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack {
                    IconMenuButton(icon: "person.3.fill", description: "Create New Account or Switch to Existing Account") {
                        ForEach(userViewModel.accounts) { account in
                            Button {
                                userViewModel.setCurrentAccount(newAccount: account)
                            } label: {
                                HStack {
                                    if userViewModel.currentAccount?.id == account.id {
                                        Image(systemName: "xmark")
                                            .font(.callout)
                                    }
                                    
                                    Text("\(account.displayName)")
                                }
                            }
                        }
                        
                        if !userViewModel.userHasBothAccounts() {
                            Button {
                                userViewModel.isCreateRoleSheet.toggle()
                            } label: {
                                Label("Create User Account", systemImage: "plus")
                            }
                            
                        }
                    }
                }
                .foregroundStyle(Theme.lightOrange)
            }
        }
        .onAppear {
            if let userId = userViewModel.user?.id {
                userViewModel.getAllUserAccountsFromDatabase()
                userViewModel.getCurrentAccount(userId: userId)
            }
        }
        .task {
            if let userId = userViewModel.user?.id {
                do {
                    try await syncServiceViewModel.syncAllTables(userId: userId)
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
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
                    
                    if await !NotificationService.getAuthStatus() {
                        await NotificationService.request()
                    }
                }
            }
        })
    }
}
 
#Preview { 
    @Previewable @State var userViewModel = SharedUserViewModel(repository: RepositoryPreview.shared)
    @Previewable @State var networkMonitorViewModel = NetworkMonitorViewModel.shared
    
    NavigationStack {
        DashboardView(
            userViewModel: userViewModel
        )
        .messagePopover()
    }
    .navigationStackTint()
    .previewEnvirments()
}
