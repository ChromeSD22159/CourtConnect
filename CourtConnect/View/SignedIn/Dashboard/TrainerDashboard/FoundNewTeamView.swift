//
//  FoundNewTeamView.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 29.01.25.
//
import SwiftUI
import PhotosUI

struct FoundNewTeamView: View {
    @Environment(\.errorHandler) var errorHandler
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: FoundNewTeamViewModel
  
    let userAccount: UserAccount
    let userProfile: UserProfile
    
    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            
            VStack(spacing: 20) {
                HStack(alignment: .bottom, spacing: 20) {
                    
                    if let avatarImage = viewModel.avatarImage {
                        ZStack {
                            avatarImage
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                                .mask {
                                    Circle()
                                }
                            
                            Circle()
                                .stroke(.black, lineWidth: 3)
                                .frame(width: 100, height: 100)
                        }
                    } else {
                        ZStack {
                            Image(.basketballPlayer)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 75, height: 75)
                                .mask {
                                    Circle()
                                }
                            
                            Circle()
                                .stroke(.black, lineWidth: 3)
                                .frame(width: 75, height: 75)
                        }
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Select image")
                        PhotosPicker("Select image", selection: $viewModel.avatarItem, matching: .images)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background {
                                RoundedRectangle(cornerRadius: 10).fill(Theme.headline)
                            }
                    }
                    
                    Spacer()
                }
                .padding()
                .background(Material.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 15))
                
                VStack(alignment: .leading) {
                    Text("* Required").font(.caption2)
                    TextField("Team Name", text: $viewModel.teamName, prompt: Text("Team Name"))
                        .textFieldStyle(.roundedBorder)
                }
                
                VStack(alignment: .leading) {
                    Text("(Optimal)").font(.caption2)
                    TextField("Headcoach", text: $viewModel.headcoach, prompt: Text("Headcoach"))
                        .textFieldStyle(.roundedBorder)
                }
                
                VStack(alignment: .leading) {
                    Text("* Required").font(.caption2)
                    TextField("Association e-mail", text: $viewModel.email, prompt: Text("Association e-mail"))
                        .textFieldStyle(.roundedBorder)
                }
                
                Button("Create Team") {
                    Task {
                        do {
                            try await viewModel.createTeam(userAccount: userAccount, userProfile: userProfile)
                            
                            dismiss() 
                        } catch {
                            errorHandler.handleError(error: error)
                        }
                    }
                }
                .tint(Theme.darkOrange)
                .buttonStyle(.borderedProminent)
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .blur(radius: viewModel.isLoading ? 2 : 0)
            .animation(.easeInOut, value: viewModel.isLoading)
            .onChange(of: viewModel.avatarItem) {
                viewModel.changeImage()
            }
            
            LoadingCard(isLoading: $viewModel.isLoading)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Image(systemName: "figure")
            }
        }
        .navigationTitle("Found New Team")
        .navigationBarTitleDisplayMode(.inline)
        .contentMargins(.top, 20)
    }
}

#Preview {
    @Previewable @State var viewModel = FoundNewTeamViewModel(repository: RepositoryPreview.shared)
    @Previewable @State var userProfile = UserProfile(userId: UUID(), firstName: "Spieler", lastName: "Spieler", birthday: "22.11.1986")
    @Previewable @State var userAccount = UserAccount(userId: UUID(), teamId: UUID(), position: UserRole.player.rawValue, role: UserRole.player.rawValue, displayName: "Spieler", createdAt: Date(), updatedAt: Date())
    
    NavigationStack {
        FoundNewTeamView(viewModel: viewModel, userAccount: userAccount, userProfile: userProfile)
    }
    .previewEnvirments()
    .navigationStackTint()
}
