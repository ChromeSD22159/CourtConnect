//
//  FoundNewTeamView.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 29.01.25.
//
import SwiftUI
import PhotosUI

struct FoundNewTeamView: View {
    @ObservedObject var viewModel: FoundNewTeamViewModel
    
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
                        Text("Choose Image")
                        PhotosPicker("Bild auswählen", selection: $viewModel.avatarItem, matching: .images)
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
                    TextField("Verbands E-Mail", text: $viewModel.headcoach, prompt: Text("Headcoach"))
                        .textFieldStyle(.roundedBorder)
                }
                
                Button("Create Team") {
                    //viewModel.createTeam()
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
            
            animationOverlay()
            
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
    
    @ViewBuilder func animationOverlay() -> some View {
        if viewModel.isLoading {
            LoadingCard()
                .opacity(viewModel.isLoading ? 1 : 0)
                .animation(.easeInOut.delay(0.5), value: viewModel.isLoading)
        }
    }
}

#Preview {
    @Previewable @State var viewModel = FoundNewTeamViewModel(repository: RepositoryPreview.shared)
    NavigationStack {
        FoundNewTeamView(viewModel: viewModel)
    }
    .previewEnvirments()
    .navigationStackTint()
}
