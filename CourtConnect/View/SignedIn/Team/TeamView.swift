//
//  TeamView.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 29.01.25.
//
import SwiftUI

struct TeamView: View {
    @Environment(\.messagehandler) var messagehandler
    @Environment(\.scenePhase) var scenePhase
    
    @State var teamViewViewModel: TeamViewViewModel =  TeamViewViewModel()
    
    var body: some View {
        ZStack {
            if (teamViewViewModel.currentTeam != nil) {
                ScrollView {
                    VStack {
                        DocumentScrollView(documents: teamViewViewModel.documents, onClick: teamViewViewModel.setDocument)
                        
                        LazyVStack(spacing: 20) {
                            Section {
                                LazyVStack {
                                    ForEach(teamViewViewModel.teamPlayers) { player in
                                        PlayerRow(member: player, isTrainer: false)
                                    }
                                }
                            } header: {
                                HStack {
                                    UpperCasedheadline(text: "Player") 
                                    Spacer()
                                }
                            }
                            
                            Section {
                                LazyVStack {
                                    ForEach(teamViewViewModel.teamTrainers) { trainer in
                                        PlayerRow(member: trainer, isTrainer: true)
                                    }
                                }
                            } header: {
                                HStack {
                                    UpperCasedheadline(text: "Coach")
                                    Spacer()
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        CalendarCard(termine: teamViewViewModel.termine, editable: false)
                            .padding(.horizontal)
                            .padding(.vertical)
                    }
                } 
                .scrollIndicators(.hidden)
                .opacity(teamViewViewModel.selectedDocument != nil ? 0.5 : 1.0)
                .blur(radius: teamViewViewModel.selectedDocument != nil ? 2 : 0)
                .animation(.easeInOut, value: teamViewViewModel.selectedDocument)
            } else {
                TeamUnavailableView()
            }
            
            DocumentOverlayView(document: $teamViewViewModel.selectedDocument)
        } 
        .navigationTitle(title: "\(teamViewViewModel.currentTeam?.teamName ?? "")")
        .reFetchButton(isFetching: $teamViewViewModel.isfetching, onTap: {
            teamViewViewModel.fetchDataFromRemote()
        })
        .teamInfoButton(team: teamViewViewModel.currentTeam) 
        .onAppear {
            teamViewViewModel.inizialize()
        }
        .onChange(of: scenePhase) {
            if scenePhase == .active {
                teamViewViewModel.fetchDataFromRemote()
            }
        }
    }
} 
 
extension String {
    func localizedStringKey() -> LocalizedStringKey {
        return LocalizedStringKey(self)
    }
}
 
extension Image {
    @MainActor func render(scale displayScale: CGFloat = 1.0) -> UIImage? {
        let renderer = ImageRenderer(content: self)

        renderer.scale = displayScale
        
        return renderer.uiImage
    }
    
    @MainActor func convertImageToData() async -> Data? {
        guard let uiImage = self.render()  else { return nil } // Helper function (see below)
        return uiImage.jpegData(compressionQuality: 0.8) // Or pngData() for PNG
    }
}
