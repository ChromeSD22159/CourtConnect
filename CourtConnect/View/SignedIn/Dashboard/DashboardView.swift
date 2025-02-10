//
//  DashboardView.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 16.01.25.
//
import SwiftUI 

struct DashboardView: View {
    @ObservedObject var userViewModel: SharedUserViewModel
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
                case .player: PlayerDashboard(userViewModel: userViewModel, dashBoardViewModel: dashBoardViewModel)
                case .trainer: TrainerDashboard(userViewModel: userViewModel, dashBoardViewModel: dashBoardViewModel)
                case .admin: EmptyView()
                }
            } else {
                DashboarAccountSwitch(accounts: userViewModel.accounts) { account in
                    userViewModel.setCurrentAccount(newAccount: account)
                }
                .padding(.horizontal, 16)
            }
        }
        .contentMargins(.top, 20)
        .contentMargins(.bottom, 75)
        .scrollIndicators(.hidden)
        .errorPopover()
        .navigationTitle("Dashboard")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $userViewModel.isCreateRoleSheet, onDismiss: {
            userViewModel.getAllUserAccountsFromDatabase()
           
            guard let userId = userViewModel.user?.id else { return }
            userViewModel.getCurrentAccount(userId: userId)
        }, content: {
            if let userId = userViewModel.user?.id {
                CreateUserAccountView(userId: userId)
            }
        })
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Image(systemName: "figure")
                    .onTapGesture {
                        Task {
                            do {
                                if let userId = userViewModel.user?.id {
                                    try await userViewModel.syncAllTables(userId: userId)
                                    userViewModel.getAllUserAccountsFromDatabase()
                                    userViewModel.getCurrentAccount(userId: userId)
                                }
                            } catch {
                                print(error)
                            }
                        }
                    }
            }
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
                        
                        Button {
                            userViewModel.isCreateRoleSheet.toggle()
                        } label: {
                            Label("Create User Account", systemImage: "plus")
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
