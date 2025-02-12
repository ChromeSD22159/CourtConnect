//
//  FoundNewTeamView.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 29.01.25.
//
import SwiftUI
import PhotosUI

struct FoundNewTeamView: View {
    @Environment(\.dismiss) var dismiss
    @State var viewModel: FoundNewTeamViewModel = FoundNewTeamViewModel()
    var body: some View {
        ZStack {
            Theme.backgroundGradient.ignoresSafeArea()
            
            VStack(spacing: 20) {
                HStack(alignment: .bottom, spacing: 20) {
                    
                    if let image = viewModel.image {
                        ZStack {
                            image
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
                        PhotosPicker("Select image", selection: $viewModel.item, matching: .images)
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
                    viewModel.createTeam() 
                }
                .tint(Theme.darkOrange)
                .buttonStyle(.borderedProminent)
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .blur(radius: viewModel.isLoading ? 2 : 0)
            .animation(.easeInOut, value: viewModel.isLoading)
            .onChange(of: viewModel.item) {
                viewModel.setImage()
            }
            
            LoadingCard(isLoading: $viewModel.isLoading)
        }
        .messagePopover()
        .onAppear(perform: viewModel.inizializeAuth)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Image(systemName: "figure")
            }
        } 
        .navigationTitle(title: "Found New Team")
        .contentMargins(.top, 20)
    }
}

#Preview {
    NavigationStack {
        FoundNewTeamView()
    }
    .previewEnvirments()
    .navigationStackTint()
}
