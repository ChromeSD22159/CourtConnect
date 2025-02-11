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
        .navigationTitle("Dashboard")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $viewModel.isCreateRoleSheet, onDismiss: {
            viewModel.getAllUserAccounts()
            viewModel.getCurrentAccount()
        }, content: {
            if let user = viewModel.user {
                CreateUserAccountView(userId: user.id)
            }
        })
        .toolbar { 
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack {
                    IconMenuButton(icon: "person.3.fill", description: "Create New Account or Switch to Existing Account") {
                        ForEach(viewModel.userAccounts) { account in
                            Button {
                                viewModel.setCurrentAccount(newAccount: account)
                            } label: {
                                HStack {
                                    if viewModel.userAccount?.id == account.id {
                                        Image(systemName: "xmark")
                                            .font(.callout)
                                    }
                                    
                                    Text("\(account.displayName)")
                                }
                            }
                        }
                        
                        Button {
                            viewModel.isCreateRoleSheet.toggle()
                        } label: {
                            Label("Create User Account", systemImage: "plus")
                        }
                    }
                }
                .foregroundStyle(Theme.lightOrange)
            }
        }
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
