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
    var termine: [Termin] = []
    
    var teamPlayers: [MemberProfile] = []
    var teamTrainers: [MemberProfile] = []
    
    init(repository: BaseRepository, account: UserAccount?) {
        self.repository = repository
        self.account = account
         
        self.getTeam()
        self.getAllDocuments()
        self.getTeamTermine()
        self.getTeamMembers()
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
     
    func getTeamTermine() {
        do {
            guard let team = currentTeam else { throw TeamError.userHasNoTeam }
            termine = try repository.teamRepository.getTeamTermine(for: team.id)
        } catch {
            print(error)
        }
    }
    
    func getTeamMembers() {
        do {
            guard let teamId = currentTeam?.id else { throw TeamError.teamNotFound }
             
            let teamMember = try repository.teamRepository.getTeamMembers(for: teamId)
             
            let teamPlayers = teamMember.filter { $0.role == UserRole.player.rawValue }
            for player in teamPlayers {
                if let playerAccount = try repository.accountRepository.getAccount(id: player.userAccountId),
                    let userProfile = try repository.userRepository.getUserProfileFromDatabase(userId: playerAccount.userId) {
                    let userStatistic = try repository.teamRepository.getMemberAvgStatistic(for: playerAccount.id)
                    let profile = MemberProfile(
                        firstName: userProfile.firstName,
                        lastName: userProfile.lastName,
                        shirtNumber: player.shirtNumber,
                        avgFouls: userStatistic?.avgFouls ?? -0,
                        avgTwo: userStatistic?.avgTwoPointAttempts ?? 0,
                        avgtree: userStatistic?.avgThreePointAttempts ?? 0,
                        avgPoints: userStatistic?.avgPoints ?? 0
                    )
                    self.teamPlayers.append(profile)
                }
            }
             
            let teamTrainers = teamMember.filter { $0.role == UserRole.trainer.rawValue }
            for trainer in teamTrainers {
                if let trainerAccount = try repository.accountRepository.getAccount(id: trainer.userAccountId),
                    let userProfile = try repository.userRepository.getUserProfileFromDatabase(userId: trainerAccount.userId) {
                    let profile = MemberProfile(firstName: userProfile.firstName, lastName: userProfile.lastName, avgFouls: 0, avgTwo: 0, avgtree: 0, avgPoints: 0)
                    self.teamTrainers.append(profile)
                }
            }
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
            if (teamViewViewModel.currentTeam != nil) {
                ScrollView {
                    VStack {
                        DocumentScrollView(documents: teamViewViewModel.documents)
                        
                        LazyVStack(spacing: 20) {
                            Section {
                                LazyVStack {
                                    ForEach(teamViewViewModel.teamPlayers) { player in
                                        PlayerRow(member: player, isTrainer: false)
                                    }
                                }
                            } header: {
                                HStack {
                                    Text("Player")
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
                                    Text("Trainer")
                                    Spacer()
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        CalendarCard(termine: teamViewViewModel.termine)
                            .padding(.horizontal)
                            .padding(.vertical)
                        
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
                .contentMargins(.bottom, 75)
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
    let member: MemberProfile
    let isTrainer: Bool
    
    init(member: MemberProfile, isTrainer: Bool) {
        self.member = member
        self.isTrainer = isTrainer
    }
    
    var body: some View {
        VStack(spacing: 20) {
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    if let number = member.shirtNumber {
                        Text("\(member.fullName) (\(number))")
                            .fontWeight(.bold)
                    } else {
                        Text("\(member.fullName)")
                            .fontWeight(.bold)
                    }
                     
                    if let position = member.position {
                        Text(position)
                            .font(.footnote)
                    }
                }
                Spacer()
                if !isTrainer {
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
            }
            .padding()
            .background(Material.ultraThinMaterial.opacity(0.8))
            .clipShape(RoundedRectangle(cornerRadius: 15))
            
            if isExpant {
                HStack(spacing: 25) {
                    valueIcon(icon: "basketball.circle", value: member.avgFouls)
                    
                    valueIcon(icon: "basketball.circle.fill", value: member.avgTwo)
                    
                    valueIcon(icon: "figure.basketball", value:  member.avgtree)
                    
                    valueIcon(icon: "trophy.fill", value: member.avgPoints)
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
    @Previewable @State var userViewModel = SharedUserViewModel(repository: RepositoryPreview.shared)
    
    NavigationStack {
        MessagePopover {
            TeamView(userViewModel: userViewModel)
        }
    }
    .previewEnvirments()
    .navigationStackTint()
}
