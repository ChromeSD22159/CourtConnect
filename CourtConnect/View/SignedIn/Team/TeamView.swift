//
//  TeamView.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 29.01.25.
//
import SwiftUI

@Observable @MainActor class TeamViewViewModel {
    let repository: BaseRepository
    var currentTeam: Team?
    var account: UserAccount?
    var qrCode: UIImage?
    var showQrCode = false
    
    init(repository: BaseRepository, account: UserAccount?) {
        self.repository = repository
        self.account = account
         
        self.getTeam()
    }
    
    private func getTeam() {
        guard let account = account, let teamId = account.teamId else { return }
        
        do {
            currentTeam = try self.repository.teamRepository.getTeam(for: teamId)
        } catch {
            print(error)
        }
    }
}

struct TeamView: View {
    @Environment(\.messagehandler) var messagehandler
    
    @ObservedObject var userViewModel: SharedUserViewModel
    @State var teamViewViewModel: TeamViewViewModel
    
    init(userViewModel: SharedUserViewModel) {
        self.userViewModel = userViewModel
        self.teamViewViewModel = TeamViewViewModel(repository: userViewModel.repository, account: userViewModel.currentAccount)
    }
    
    var body: some View {
        VStack {
            if let qrCode = teamViewViewModel.qrCode, teamViewViewModel.showQrCode {
                Image(uiImage: qrCode)
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
            }
        }
        .navigationTitle(teamViewViewModel.currentTeam?.teamName ?? "TeamName")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if let team = teamViewViewModel.currentTeam {
                    IconMenuButton(icon: "info.bubble", description: team.teamName.localizedStringKey()) {
                        Button {
                            ClipboardHelper.copy(text: team.joinCode)
                            
                            messagehandler.handleMessage(message: InAppMessage(title: "TeamId Kopiert"))
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

extension String {
    func localizedStringKey() -> LocalizedStringKey {
        return LocalizedStringKey(self)
    }
}

#Preview {
    @Previewable @State var userViewModel = SharedUserViewModel(repository: RepositoryPreview.shared) 
    
    NavigationStack {
        MessagePopover {
            TeamView(userViewModel: userViewModel)
        }
    }
    .previewEnvirments()
    .navigationStackTint()
}
