//
//  TeamView.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 29.01.25.
//
import SwiftUI 
import CachedAsyncImage

struct TeamView: View {
    @Environment(\.messagehandler) var messagehandler
     
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
                                    UpperCasedheadline(text: "Trainer")
                                    Spacer()
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        CalendarCard(termine: teamViewViewModel.termine)
                            .padding(.horizontal)
                            .padding(.vertical)
                    }
                }
                .contentMargins(.bottom, 75)
                .contentMargins(.top, 20)
                .scrollIndicators(.hidden)
                .opacity(teamViewViewModel.selectedDocument != nil ? 0.5 : 1.0)
                .blur(radius: teamViewViewModel.selectedDocument != nil ? 2 : 0)
                .animation(.easeInOut, value: teamViewViewModel.selectedDocument)
            } else {
                TeamUnavailableView()
            }
            
            DocumentOberlayView(document: $teamViewViewModel.selectedDocument)
        }
        .navigationTitle(teamViewViewModel.currentTeam?.teamName ?? "")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Image(systemName: "arrow.triangle.2.circlepath.circle")
                    .rotationAnimation(isFetching: $teamViewViewModel.isfetching)
                    .onTapGesture {
                        teamViewViewModel.fetchDataFromRemote()
                    }
            }
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
        .onAppear {
            teamViewViewModel.inizialize()
        }
    }
}
 
fileprivate struct DocumentOberlayView: View {
    @Binding var document: Document?
    let viewPort = UIScreen.main.bounds.size
    
    var body: some View {
        if let document = document {
            VStack {
                VStack(spacing: 20) { 
                    
                    AsyncCachedImage(url: URL(string: document.url)!) { image in
                        image
                            .resizable()
                            .scaledToFill()
                            .clipped()
                            .frame(width: viewPort.width * 0.6, height: viewPort.width * 0.6)
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                    } placeholder: {
                        ZStack {
                            Image(systemName: "doc")
                                .font(.largeTitle)
                                .padding(20)
                        }
                    }
                    
                    HStack {
                        Text(document.name)
                        
                        Spacer()
                        
                        Image(systemName: "square.and.arrow.up")
                    }
                }
                .padding()
                .background(Material.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .shadow(radius: 10)
                .transition(
                    AnyTransition.move(edge: .bottom)
                        .combined(with: .scale(scale: 0.6, anchor: .top))
                )
                .overlay(alignment: .topTrailing, content: {
                    ZStack {
                        Circle()
                            .fill(Material.ultraThinMaterial)
                            .frame(width: 30)
                            .shadow(radius: 2, x: -5, y: 5)
                            
                        Image(systemName: "xmark")
                    }
                    .offset(x: 10, y: -10)
                    .onTapGesture {
                        self.document = nil
                    }
                })
                .frame(width: viewPort.width * 0.8, height: viewPort.width * 1.0)
            }
        }
    }
}

fileprivate struct DocumentScrollView: View {
    var documents: [Document]
    let onClick: (Document) -> Void
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
                                    
                                    AsyncCachedImage(url: URL(string: document.url)!) { image in
                                        image
                                            .resizable()
                                            .frame(width: 100, height: 100)
                                            .clipShape(RoundedRectangle(cornerRadius: 15))
                                    } placeholder: {
                                        ZStack {
                                            Image(systemName: "doc")
                                                .font(.largeTitle)
                                                .padding(20)
                                        }
                                    } 
                                    
                                    Text(document.name)
                                }
                                .onTapGesture {
                                    onClick(document)
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
            UpperCasedheadline(text: title)
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
                    valueIcon(icon: .customFigureBasketballFoul, value: member.avgFouls)
                    
                    valueIcon(icon: .customBasketball2Fill, value: member.avgTwo)
                    
                    valueIcon(icon: .customBasketball3Fill, value:  member.avgtree)
                    
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
        HStack(alignment: .center) {
            Image(systemName: icon)
                .font(.title)
            
            Text(String("x\(value)"))
                .font(.subheadline)
        }
    }
    
    @ViewBuilder func valueIcon(icon: ImageResource, value: Int) -> some View {
        HStack(alignment: .center) {
            Image(icon)
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
 
/*
#Preview {
    HStack {
        HStack(alignment: .center) {
            Image(.customFigureBasketballFoul)
                .font(.title)
            
            Text(String("x\(5)"))
                .font(.subheadline)
        }
        .frame(minWidth: 85)
        HStack(alignment: .center) {
            Image(.customBasketball2Fill)
                .font(.title)
            
            Text(String("x\(10)"))
                .font(.subheadline)
        }
        .frame(minWidth: 85)
        HStack(alignment: .center) {
            Image(.customBasketball3Fill)
                .font(.title)
            
            Text(String("x\(3)"))
                .font(.subheadline)
        }
        .frame(minWidth: 85)
        HStack(alignment: .center) {
            Image(.customFigureBasketballFoul)
                .font(.title)
            
            Text(String("x\(45)"))
                .font(.subheadline)
        }
        .background(.gray)
        .frame(minWidth: 85)
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
 */
