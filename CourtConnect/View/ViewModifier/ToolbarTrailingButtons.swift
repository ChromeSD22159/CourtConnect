//
//  ToolbarTrailingButtons.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 11.02.25.
//
import SwiftUI

extension View {
    func reFetchButton(isFetching: Binding<Bool>, onTap: @escaping () -> Void) -> some View {
        modifier(ReFetchButton(isFetching: isFetching, onTap: onTap))
    }
    
    func teamInfoButton(team: Team?) -> some View {
        modifier(TeamInfoButton(team: team))
    }
    
    func accountSwitch(viewModel: DashboardViewModel) -> some View {
        modifier(AccountSwitch(viewModel: viewModel))
    }
}

struct ReFetchButton: ViewModifier {
    @Binding var isFetching: Bool
    let onTap: () -> Void
    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Image(systemName: "arrow.triangle.2.circlepath.circle")
                        .foregroundStyle(Theme.headline)
                        .rotationEffect(.degrees(isFetching ? 360 : 0))
                        .animation(
                            isFetching ? Animation.linear(duration: 1).repeatForever(autoreverses: false) : .default,
                            value: isFetching
                        )
                        .onTapGesture {
                            onTap()
                        }
                }
            }
    }
}

struct TeamInfoButton: ViewModifier {
    let team: Team?
    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if let team = team {
                        IconMenuButton(icon: "info.bubble", description: team.teamName.localizedStringKey()) {
                            Button {
                                ClipboardHelper.copy(text: team.joinCode)
                                
                                InAppMessagehandlerViewModel.shared.handleMessage(message: InAppMessage(icon: .warn, title: "Teamid copied"))
                            } label: {
                                Label("Copy Team ID", systemImage: "arrow.right.doc.on.clipboard")
                            }
                            Button {
                                
                            } label: {
                                Label("Show QR Code", systemImage: "qrcode")
                            }
                            ShareLink(item: "TeamID: \(team.joinCode)")
                        }
                    }
                }
            }
    }
}

struct AccountSwitch: ViewModifier {
    let viewModel: DashboardViewModel
    func body(content: Content) -> some View {
        content
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
                            /*
                            Button("Remove CurrentUser") {
                               viewModel.removeCurrentUser()
                            }
                            */
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
    }
}

#Preview {
    @Previewable @State var isFetching = false
    ZStack {
        EmptyView()
    }.reFetchButton(isFetching: $isFetching, onTap: {
        isFetching.toggle()
    })
}
