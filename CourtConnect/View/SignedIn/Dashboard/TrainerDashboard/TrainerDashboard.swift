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
    @ObservedObject var syncVM = SyncViewModel.shared
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
        .onReceive(syncVM.$isfetching) { value in
            if value == false {
                trainerDashboardViewModel.loadLocalData()
            }
        }
        .onChange(of: scenePhase) {
            if scenePhase == .active {
                trainerDashboardViewModel.fetchData()
            }
        }
        .navigationTitle("Coach Dashboard")
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
                    ZStack {
                        Theme.backgroundGradient.ignoresSafeArea()
                        
                        EnterCodeView()
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
                        TeamRequestsView()
                    } label: {
                        IconCard(systemName: "person.fill.questionmark", title: "Join Requests", background: Material.ultraThinMaterial, badge: trainerDashboardViewModel.requests)
                    }
                    
                    NavigationLink {
                        AddStatisticView()
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
                        ManageDocumentsView()
                    } label: {
                        CardIcon(text: "Manage Documents", systemName: "doc.badge.ellipsis")
                    }

                    NavigationLink {
                        AbsenceOverview()
                    } label: {
                        CardIcon(text: "Show Absenses", systemName: "person.crop.circle.badge.clock")
                    }
                }
            }
            
            ConfirmationTermin(attendanceTermines: trainerDashboardViewModel.attendancesTermines) { attendance in
                trainerDashboardViewModel.updateTerminAttendance(attendance: attendance)
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 16)
            
            CalendarCard(title: "Edit appointment", termine: trainerDashboardViewModel.termine, editable: true, onChanged: {
                trainerDashboardViewModel.loadLocalData()
            })
            .padding(.vertical, 16)
            .padding(.horizontal, 16)
              
            NavigationLink {
                NoteView()
            } label: {
                ShowNotesCard()
            } 
            
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

fileprivate struct ShowNotesCard: View {
    var body: some View {
        VStack(spacing: 15) {
            ZStack {
                LinearGradient(
                    stops: [
                        Gradient.Stop(color: Theme.headline, location: 0.00),
                        Gradient.Stop(color: Theme.headlineReversed, location: 1.00)
                    ],
                    startPoint: UnitPoint(x: 1, y: 0),
                    endPoint: UnitPoint(x: 0, y: 1)
                )
                .opacity(0.9)
                .blur(radius: 10)
                
                RoundedRectangle(cornerRadius: 35)
                    .stroke(
                        LinearGradient(
                            stops: [
                                Gradient.Stop(color: .white.opacity(0.4), location: 0.00),
                                Gradient.Stop(color: .white.opacity(0.6), location: 1.00)
                            ],
                            startPoint: UnitPoint(x: 1, y: 0),
                            endPoint: UnitPoint(x: 0, y: 1)
                        ).opacity(0.8),
                        lineWidth: 2
                    )
                    .stroke(
                        LinearGradient(
                            stops: [
                                Gradient.Stop(color: .white.opacity(0.4), location: 0.00),
                                Gradient.Stop(color: .white.opacity(0.2), location: 1.00)
                            ],
                            startPoint: UnitPoint(x: 0, y: 1),
                            endPoint: UnitPoint(x: 1, y: 0)
                        ),
                        lineWidth: 2
                    )
                    .overlay {
                        HStack {
                            Text("😜")
                                .offset(x: -30)
                                .rotationEffect(Angle(degrees: 15))
                                .clipped()
                            
                            Spacer()
                            VStack {
                                Button("Show Notes") {
                                    
                                }
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .buttonStyle(DarkButtonStlye())
                            }
                            Spacer()
                            
                            Text("🤗")
                                .offset(x: 30)
                                .rotationEffect(Angle(degrees: -15))
                                .clipped()
                        }
                        .font(.system(size: 100))
                        .clipShape(Rectangle())
                    }
            }
            .frame(height: 200)
            .borderRadius(35)
        }
        .padding()
    }
}

#Preview {
    NavigationStack {
        NavigationLink {
            NoteView()
        } label: {
            ShowNotesCard()
        }
    }
}

#Preview {
    NavigationStack {
        VStack(spacing: 15) {  
               
            SnapScrollView(horizontalSpacing: 16) {
                LazyHStack(spacing: 16) {
                    NavigationLink {
                        TeamRequestsView()
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
