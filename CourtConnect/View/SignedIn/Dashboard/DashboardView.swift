//
//  DashboardView.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 16.01.25.
//
import SwiftUI  
 
struct DashboardView: View {
    @State var viewModel = DashboardViewModel()
    var body: some View {
        ScrollView(.vertical) {
            if let userAccount = viewModel.userAccount, let role = UserRole(rawValue: userAccount.role) { 
                switch role {
                case .player: PlayerDashboard()
                case .trainer: TrainerDashboard()
                case .admin: EmptyView()
                }
            } else {
                DashboarAccountSwitch(accounts: viewModel.userAccounts) { account in
                    viewModel.setCurrentAccount(newAccount: account)
                }
                .padding(.horizontal, 16)
            }
        }
        .contentMargins(.top, 20)
        .contentMargins(.bottom, 75)
        .scrollIndicators(.hidden)
        .errorPopover()
        .navigationTitle(title: "Dashboard")
        .sheet(isPresented: $viewModel.isCreateRoleSheet, onDismiss: {
            viewModel.getAllUserAccounts()
            viewModel.getCurrentAccount()
        }, content: {
            if let user = viewModel.user {
                CreateUserAccountView(userId: user.id)
            }
        })
        .accountSwitch(viewModel: viewModel) 
        .onAppear {
            viewModel.inizialize()
        }
    }
} 
 
#Preview {
    NavigationStack {
        DashboardView()
        .messagePopover()
    }
    .navigationStackTint()
    .previewEnvirments()
}
