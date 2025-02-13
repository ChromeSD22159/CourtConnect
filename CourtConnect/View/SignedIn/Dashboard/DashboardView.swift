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
                if !viewModel.userAccounts.isEmpty {
                    
                    if viewModel.userAccounts.isEmpty {
                        VStack(spacing: 25) {
                            ListInfomationSection(text: "Hier kannst du dein erstes Konto anlegen. Du hast die Möglichkeit, mehrere Konten zu erstellen und jederzeit zwischen ihnen zu wechseln – ideal für verschiedene Rollen oder Profile.")
                            Button {
                                viewModel.isCreateRoleSheet.toggle()
                            } label: {
                                Label("Erstelle dein ersten Account!", systemImage: "plus")
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    } else {
                        VStack(spacing: 75) {
                            
                            VStack(spacing: 25) {
                                ListInfomationSection(text: "Hier kannst du ein weiteres Konto anlegen, um flexibel zwischen Rollen oder Profilen zu wechseln.")
                                Button {
                                    viewModel.isCreateRoleSheet.toggle()
                                } label: {
                                    Label("Neuen Account erstellen", systemImage: "plus")
                                }
                                .buttonStyle(.borderedProminent)
                            }
                            
                            VStack {
                                Text("Wahle einen deiner UserAccount")
                                DashboarAccountSwitch(accounts: viewModel.userAccounts) { account in
                                    viewModel.setCurrentAccount(newAccount: account)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        
                    }
                } else {
                    Text("Erstelle deinen ersten UserAccount")
                }
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
