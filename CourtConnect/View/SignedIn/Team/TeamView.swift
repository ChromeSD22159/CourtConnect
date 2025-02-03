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
    
    var documents: [Document] = []
    
    init(repository: BaseRepository, account: UserAccount?) {
        self.repository = repository
        self.account = account
         
        self.getTeam()
        self.getAllDocuments()
    }
    
    private func getAllDocuments() {
        do {
            guard let team = currentTeam else { return }
            self.documents = try repository.documentRepository.getDocuments(for: team.id)
        } catch {
            print(error)
        }
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
        ZStack {
            if let currentTeam = teamViewViewModel.currentTeam {
                ScrollView {
                    VStack {
                        DocumentScrollView(documents: teamViewViewModel.documents)
                        
                        LazyVStack(spacing: 20) {
                            Section {
                                LazyVStack {
                                    PlayerRow(fullname: "Nico Kohler", number: 14)
                                    PlayerRow(fullname: "Frederik Kohler", number: 22)
                                    PlayerRow(fullname: "Sabina Hodel", number: 21)
                                    PlayerRow(fullname: "Joker Hodel", number: 7)
                                }
                            } header: {
                                HStack {
                                    Text("Player")
                                    Spacer()
                                }
                            }
                            
                            Section {
                                LazyVStack {
                                    PlayerRow(fullname: "Trainer Fabio")
                                }
                            } header: {
                                HStack {
                                    Text("Trainer")
                                    Spacer()
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        ForEach(teamViewViewModel.documents) { document in
                            AsyncImage(url: URL(string: document.url)) { image in
                                image.resizable()
                            } placeholder: {
                                ProgressView()
                            }
                            .frame(width: 300, height: 300)
                        }
                    }
                }
            } else {
                TeamUnavailableView()
            }
            
        }
        .navigationTitle(teamViewViewModel.currentTeam?.teamName ?? "")
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

fileprivate struct DocumentScrollView: View {
    var documents: [Document]
    var body: some View {
        Row(title: "Documents") {
            if !documents.isEmpty {
                SnapScrollView {
                    LazyHStack {
                        ForEach(documents) { document in
                            ZStack {
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Material.ultraThinMaterial)
                                
                                VStack {
                                    Image(systemName: "doc")
                                        .font(.largeTitle)
                                        .padding(20)
                                   
                                    Text(document.name)
                                }
                            }
                            .frame(width: 150, height: 150)
                        }
                    }
                }
                .frame(height: 180)
            } else {
                ZStack {
                    SnapScrollView {
                        LazyHStack {
                            ForEach((1...3), id: \.self) { document in
                                ZStack {
                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(Material.ultraThinMaterial)
                                    
                                    VStack {
                                        Image(systemName: "doc")
                                            .font(.largeTitle)
                                            .padding(20)
                                       
                                        Text("File \(document)")
                                    }
                                }
                                .frame(width: 150, height: 150)
                            }
                        }
                    }
                    .blur(radius: 3)
                    .opacity(0.5)
                    
                    Text("No Documents Avaible")
                }
                .frame(height: 180)
            }
        }
    }
}

fileprivate struct Row<Content: View>: View {
    let title: String
    @ViewBuilder var content: () -> Content
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .padding(.horizontal)
            
            content()
        }
    }
}

fileprivate struct PlayerRow: View {
    @State var isExpant = false
    @State var isPlayerSheet = false
    let fullname: String
    let number: Int?
    
    init(fullname: String, number: Int? = nil) {
        self.fullname = fullname
        self.number = number
    }
    
    var body: some View {
        VStack(spacing: 20) {
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    if let number = number {
                        Text("\(fullname) (\(number))")
                            .fontWeight(.bold)
                    } else {
                        Text("\(fullname)")
                            .fontWeight(.bold)
                    }
                     
                    Text("Point gaurd")
                        .font(.footnote)
                }
                Spacer()
                VStack {
                    Image(systemName: "chevron.down")
                        .rotationEffect(.degrees(isExpant ? 0 : -90))
                        .animation(.easeInOut, value: isExpant)
                        .background {
                            Rectangle()
                                .fill(.black.opacity(0.0001))
                                .frame(width: 150, height: 40)
                                .onTapGesture {
                                    withAnimation(.easeInOut) {
                                        isExpant.toggle()
                                    }
                                }
                        }
                }
                
            }
            .padding()
            .background(Material.ultraThinMaterial.opacity(0.8))
            .clipShape(RoundedRectangle(cornerRadius: 15))
            
            if isExpant {
                HStack(spacing: 25) {
                    valueIcon(icon: "basketball.circle", value: 15)
                    
                    valueIcon(icon: "basketball.circle.fill", value: 5)
                    
                    valueIcon(icon: "figure.basketball", value: 25)
                    
                    valueIcon(icon: "trophy.fill", value: 25)
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
        }
        .background(Material.ultraThinMaterial.opacity(0.8))
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .sheet(isPresented: $isPlayerSheet) {
            NavigationStack {
                ScrollView {
                    
                }
                .navigationTitle("")
            }
        }
    }
    
    @ViewBuilder func valueIcon(icon: String, value: Int) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.title)
            
            Text(String("x\(value)"))
                .font(.subheadline)
        }
    }
}

extension String {
    func localizedStringKey() -> LocalizedStringKey {
        return LocalizedStringKey(self)
    }
}

#Preview {
    ScrollView {
        LazyVStack(spacing: 20) {
            Section {
                LazyVStack {
                    PlayerRow(fullname: "Nico Kohler", number: 14)
                    PlayerRow(fullname: "Frederik Kohler", number: 22)
                    PlayerRow(fullname: "Sabina Hodel", number: 21)
                    PlayerRow(fullname: "Joker Hodel", number: 7)
                }
            } header: {
                HStack {
                    Text("Player")
                    Spacer()
                }
            }
            
            Section {
                LazyVStack {
                    PlayerRow(fullname: "Trainer Fabio")
                }
            } header: {
                HStack {
                    Text("Trainer")
                    Spacer()
                }
            }
        }
    }
    .padding(.horizontal)
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
