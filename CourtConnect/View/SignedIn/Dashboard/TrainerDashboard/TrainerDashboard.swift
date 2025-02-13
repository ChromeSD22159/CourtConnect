//
//  TrainerDashboard.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 27.01.25.
//
import SwiftUI
 
struct TrainerDashboard: View {
    @Environment(\.scenePhase) var scenePhase
    @State var trainerDashboardViewModel = TrainerDashboardViewModel()
    
    var body: some View {
        VStack(spacing: 15) {
            if trainerDashboardViewModel.currentTeam != nil {
                HasTeam(trainerDashboardViewModel: trainerDashboardViewModel)
            } else {
                HasNoTeam(trainerDashboardViewModel: trainerDashboardViewModel)
                .padding(.horizontal, 16)
            }
            
            ConfirmButtonLabel(confirmButtonDialog: ConfirmButtonDialog(
                systemImage: "trash",
                buttonText: "Delete Coach account",
                question: "Delete your Account",
                message: "Are you sure you want to delete your account? This action cannot be undone.",
                action: "Delete",
                cancel: "Cancel"
            ), material: .ultraThinMaterial) {
                trainerDashboardViewModel.deleteUserAccount()
            }
            .padding(.bottom, 50)
            .padding(.horizontal, 16)
        }
        .reFetchButton(isFetching: $trainerDashboardViewModel.isfetching, onTap: {
            trainerDashboardViewModel.fetchDataFromRemote()
        }) 
        .onAppear {
            trainerDashboardViewModel.inizialize() 
        }
        .onChange(of: scenePhase) {
            if scenePhase == .active {
                trainerDashboardViewModel.fetchDataFromRemote()
            }
        }
        .navigationTitle("Coach")
    }
}

fileprivate struct HasNoTeam: View {
    @Bindable var trainerDashboardViewModel: TrainerDashboardViewModel
    
    var body: some View {
        VStack {
            NavigationLink {
                FoundNewTeamView()
                    .onDisappear { trainerDashboardViewModel.getTeam() }
            } label: {
                RoundedIconTextCard(icon: "person.crop.circle.badge.plus", title: "Found team now!", description: "Start your own team and manage players and training sessions.")
            }
            
            NavigationLink {
                SearchTeam()
            } label: {
                RoundedIconTextCard(icon: "person.badge.plus", title: "Join a Team!", description: "Send a request to join a team as a trainer and start managing players and training sessions.")
            }
            
            RoundedIconTextCard(icon: "qrcode.viewfinder", title: "Join with Team ID!", description: "Enter a Team ID to instantly join an existing team and start managing players and training sessions.")
                .onTapGesture {
                    trainerDashboardViewModel.isEnterCode.toggle()
                }
                .sheet(isPresented: $trainerDashboardViewModel.isEnterCode, onDismiss: {
                    trainerDashboardViewModel.getTeam()
                }) {
                    if let userAccount = trainerDashboardViewModel.userAccount {
                        ZStack {
                            Theme.backgroundGradient.ignoresSafeArea()
                            
                            EnterCodeView(userAccount: userAccount)
                        }
                    }
                }
        }
       
    }
}

fileprivate struct HasTeam: View {
    @ObservedObject var trainerDashboardViewModel: TrainerDashboardViewModel
    
    var body: some View {
        VStack {
            SnapScrollView(horizontalSpacing: 16) {
                LazyHStack(spacing: 16) {
                    NavigationLink {
                        if let userId = trainerDashboardViewModel.user?.id, let teamId = trainerDashboardViewModel.currentTeam?.id {
                            TeamRequestsView(teamId: teamId, userId: userId)
                        }
                    } label: {
                        IconCard(systemName: "person.fill.questionmark", title: "Join Requests", background: Material.ultraThinMaterial)
                    }
                    
                    NavigationLink {
                        if let teamId = trainerDashboardViewModel.currentTeam?.id,
                           let userId = trainerDashboardViewModel.user?.id {
                            AddStatisticView(teamId: teamId, userId: userId)
                        } 
                    } label: {
                        IconCard(systemName: "chart.xyaxis.line", title: "Statistics", background: Material.ultraThinMaterial)
                    }
                    
                    NavigationLink {
                        ManageTeamView()
                    } label: {
                        IconCard(systemName: "23.square", title: "Manage Team", background: Material.ultraThinMaterial)
                    }
                     
                    if trainerDashboardViewModel.isAdmin() {
                        NavigationLink {
                            AdminDashboardView()
                        } label: {
                            IconCard(systemName: "square.grid.2x2", title: "Admin Dashboard", background: Material.ultraThinMaterial)
                        }
                    }
                }
                .frame(height: 150)
            }
            
            Grid(horizontalSpacing: 16, verticalSpacing: 16) {
                GridRow {
                    CardIcon(text: "Add Document", systemName: "doc.badge.plus")
                        .onTapGesture { trainerDashboardViewModel.isDocumentSheet.toggle() }
                    
                    CardIcon(text: "Plan appointment", systemName: "calendar.badge.plus")
                        .onTapGesture { trainerDashboardViewModel.isPlanAppointmentSheet.toggle() }
                }
                GridRow {
                    NavigationLink {
                        // TODO:
                    } label: {
                        CardIcon(text: "Manage Documents", systemName: "doc.badge.ellipsis")
                    }

                    NavigationLink {
                       // TODO:
                    } label: {
                        CardIcon(text: "Show Absenses", systemName: "person.crop.circle.badge.clock")
                    }
                }
                GridRow {
                    CardIcon(text: "Show Join QR Code", systemName: "qrcode.viewfinder")
                        .onTapGesture { trainerDashboardViewModel.showQrSheet.toggle() }
                    
                    CardIcon(text: "Generates a\nnew team code", systemName: "qrcode")
                        .onTapGesture { trainerDashboardViewModel.isGenerateNewCodeSheet.toggle() }
                }
            }
            
            CalendarCard(title: "Edit appointment", termine: trainerDashboardViewModel.termine, editable: true, onChanged: {
                trainerDashboardViewModel.getTeamTermine()
            })
            .padding(.vertical, 16)
            .padding(.horizontal, 16)
             
            ConfirmButtonLabel(confirmButtonDialog: ConfirmButtonDialog(
                systemImage: "iphone.and.arrow.right.inward",
                buttonText: "Leave Team",
                question: "Want leave the Team?",
                message: "Are you sure you want to leave the Team? This action cannot be undone.",
                action: "Leave",
                cancel: "Cancel"
            ), material: .ultraThinMaterial) {
                trainerDashboardViewModel.leaveTeam(role: .coach)
            }
            .padding(.horizontal, 16)
        }
        .sheet(isPresented: $trainerDashboardViewModel.isDocumentSheet, content: {
            DocumentSheet()
        })
        .sheet(isPresented: $trainerDashboardViewModel.isPlanAppointmentSheet, content: {
            PlanTerminSheet()
        })
        .sheet(isPresented: $trainerDashboardViewModel.isGenerateNewCodeSheet) {
            GenerateCodeViewSheet()
        }
        .sheet(isPresented: $trainerDashboardViewModel.showQrSheet) {
            EntryWithQRSheet(trainerDashboardViewModel: trainerDashboardViewModel)
        }
    }
} 

fileprivate struct GenerateNewJoinCodeView: View {
    @State var isGenerateCode = false
    var body: some View {
        RowLabelButton(text: "Generate new joinCode", systemImage: "qrcode.viewfinder", material: .ultraThinMaterial) {
            isGenerateCode.toggle()
        }
        .sheet(isPresented: $isGenerateCode, content: {
            ZStack {
                Theme.backgroundGradient.ignoresSafeArea()
                
                GenerateCodeViewSheet()
            }
        })
    }
}

fileprivate struct ShowTeamJoinQrCode: View {
    var QRCode: UIImage
    var joinCode: String
    @State var messagehandler: InAppMessagehandlerViewModel = InAppMessagehandlerViewModel.shared
    @State var showQrSheet = false
    var body: some View {
        RowLabelButton(text: "Show Join QR Code", systemImage: "qrcode.viewfinder", material: .ultraThinMaterial) {
            showQrSheet.toggle()
        }
        .sheet(isPresented: $showQrSheet, onDismiss: {}) {
            SheetStlye(title: "Entry with QR", detents: [.medium], isLoading: .constant(false)) {
                VStack(alignment: .center, spacing: 30) {
                    Image(uiImage: QRCode)
                        .resizable()
                        .interpolation(.none)
                        .scaledToFit()
                        .frame(width: 300, height: 300)
                    
                    HStack {
                        Button {
                            ClipboardHelper.copy(text: joinCode)
                            
                            messagehandler.handleMessage(message: InAppMessage(icon: .warn, title: "Join code copied"))
                        } label: {
                            Label("Code Team: \(joinCode)", systemImage: "arrow.right.doc.on.clipboard")
                        }
                    }
                }
                .padding()
            }
        }
    }
}

fileprivate struct EntryWithQRSheet: View {
    let trainerDashboardViewModel: TrainerDashboardViewModel
    var body: some View {
        SheetStlye(title: "Entry with QR", detents: [.medium], isLoading: .constant(false)) {
            VStack(alignment: .center, spacing: 30) {
                if let qrCode = trainerDashboardViewModel.qrCode {
                    Image(uiImage: qrCode)
                        .resizable()
                        .interpolation(.none)
                        .scaledToFit()
                        .frame(width: 300, height: 300)
                }
                
                HStack {
                    Button {
                        ClipboardHelper.copy(text: trainerDashboardViewModel.joinCode)
                        
                        InAppMessagehandlerViewModel.shared.handleMessage(message: InAppMessage(icon: .warn, title: "Join code copied"))
                    } label: {
                        Label("Code Team: \(trainerDashboardViewModel.joinCode)", systemImage: "arrow.right.doc.on.clipboard")
                    }
                }
            }
            .padding()
        }
    }
}

#Preview {
    NavigationStack {
        VStack(spacing: 15) {  
               
            SnapScrollView(horizontalSpacing: 16) {
                LazyHStack(spacing: 16) {
                    NavigationLink {
                        TeamRequestsView(teamId: UUID(uuidString: "99580a57-81dc-4f4d-adde-0e871505c679")!, userId: UUID(uuidString: "99580a57-81dc-4f4d-adde-0e871505c679")!)
                    } label: {
                        IconCard(systemName: "person.fill.questionmark", title: "Join Requests", background: Material.ultraThinMaterial)
                    }
     
                    IconCard(systemName: "person.fill.questionmark", title: "Team Members", background: Theme.headline)
                    
                    IconCard(systemName: "person.fill.questionmark", title: "Team Document", background: Material.ultraThinMaterial)
                }
                .frame(height: 150)
            }
             
            RoundedIconTextCard(icon: "person.crop.circle.badge.plus", title: "Found team now!", description: "Start your own team and manage players and training sessions.")
            
            NavigationLink {
                SearchTeam()
            } label: {
                RoundedIconTextCard(icon: "person.badge.plus", title: "Join a Team!", description: "Send a request to join a team as a trainer and start managing players and training sessions.")
            }
            
            RoundedIconTextCard(icon: "qrcode.viewfinder", title: "Join with Team ID!", description: "Enter a Team ID to instantly join an existing team and start managing players and training sessions.")
        }
    }
    .previewEnvirments()
    .navigationStackTint()
}

#Preview {
    SnapScrollView(horizontalSpacing: 0) {
        ForEach(0..<10, id: \.self) { _ in
            RoundedIconTextCard(icon: "person.crop.circle.badge.plus", title: "Found team now!", description: "Start your own team and manage players and training sessions.")
        }
    }
}
