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
                case .coach: TrainerDashboard()
                case .admin: EmptyView()
                }
            } else {
                if !viewModel.userAccounts.isEmpty {
                    
                    if viewModel.userAccounts.isEmpty {
                        VStack(spacing: 25) {
                            ListInfomationSection(text: "Here you can create your first account. You have the option of creating several accounts and switching between them at any time - ideal for player and coaches.")
                            Button {
                                viewModel.isCreateRoleSheet.toggle()
                            } label: {
                                Label("Create your first account!", systemImage: "plus")
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    } else {
                        VStack(spacing: 75) {
                            
                            VStack(spacing: 25) {
                                ListInfomationSection(text: "Here you can create another account to switch flexibly between rollers or profiles.")
                                Button {
                                    viewModel.isCreateRoleSheet.toggle()
                                } label: {
                                    Label("Create a new account", systemImage: "plus")
                                }
                                .buttonStyle(.borderedProminent)
                            }
                            
                            VStack {
                                Text("Choose one of your user account")
                                DashboarAccountSwitch(accounts: viewModel.userAccounts) { account in
                                    viewModel.setCurrentAccount(newAccount: account)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        
                    }
                } else {
                    Text("Create your first user account")
                }
            }
        }
        .contentMargins(.top, 20)
        .contentMargins(.bottom, 75)
        .scrollIndicators(.hidden) 
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
