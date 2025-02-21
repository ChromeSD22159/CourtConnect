//
//  AdminDashboardView.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 10.02.25.
//
import SwiftUI
import Auth

struct AdminDashboardView: View {
    @State var adminDashboardViewModel: AdminDashboardViewModel = AdminDashboardViewModel()
    @State var isRateSheet = false
    var body: some View {
        AnimationBackgroundChange {
            List {
                ListInfomationSection(text: "Here you can manage the team admins, change the team names or delete the team.")
                
                Section {
                    VStack(alignment: .leading) {
                        Label("Add Report", systemImage: "plus")
                            .onTapGesture {
                                isRateSheet.toggle()
                            }
                            .sheet(isPresented: $isRateSheet) {
                                CreateHourlyReportSheet()
                            }
                    }
                } header: {
                    UpperCasedheadline(text: "Trainer Hour Report")
                        //.comeSoon()
                        .betaBadge()
                }
                .blurrylistRowBackground()
                
                Section {
                    if adminDashboardViewModel.teamAdmin.isEmpty {
                        NoTeamMemberAvaible()
                    } else {
                        ForEach(adminDashboardViewModel.teamAdmin) { admin in
                            Text(admin.userProfile.fullName)
                                .swipeActions {
                                    Button("Remove Admin") {
                                        adminDashboardViewModel.removeFromAdmin(admin: admin.teamAdmin)
                                    }
                                }
                        }
                    }
                    
                    if !adminDashboardViewModel.teamTrainer.isEmpty {
                        Label("Add Admin", systemImage: "plus")
                            .onTapGesture {
                                adminDashboardViewModel.isAddAdminSheet.toggle()
                            }
                    }
                } header: {
                    UpperCasedheadline(text: "Team Admins")
                }
                .blurrylistRowBackground()
                
                Section {
                    TextField("Change Team name", text: $adminDashboardViewModel.teamName, prompt: Text("Change Team name"))
                        .padding(.horizontal)
                } header: {
                    UpperCasedheadline(text: "Change Team name")
                }
                .blurrylistRowBackground()
                 
                Section {
                    Label("Delete Team", systemImage: "trash")
                        .onTapGesture {
                            adminDashboardViewModel.isDeleteTeamDialog.toggle()
                        }
                        .confirmationDialog("Want delete the Team?", isPresented: $adminDashboardViewModel.isDeleteTeamDialog) {
                            Button("Delete", role: .destructive) { adminDashboardViewModel.deleteTeam()}
                            Button("Cancel", role: .cancel) { adminDashboardViewModel.isDeleteTeamDialog.toggle() }
                        } message: {
                            Text("Are you sure you want to delete the Team? This action cannot be undone.")
                        }
                }
                .blurrylistRowBackground()
            }
        }
        .navigationTitle(title: "Admin Dashboard")
        .listBackgroundAnimated()
        .onAppear {
            adminDashboardViewModel.inizialze()
        }
        .sheet(isPresented: $adminDashboardViewModel.isAddAdminSheet) {
            SheetStlye(title: "Add Admin", detents: [.medium, .large], isLoading: .constant(false)) {
                List {
                    if adminDashboardViewModel.teamTrainer.isEmpty {
                        NoTeamMemberAvaible()
                    } else {
                        ForEach(adminDashboardViewModel.teamTrainer) { trainer in
                            Label(trainer.userProfile.fullName, systemImage: "plus")
                                .onTapGesture {
                                    adminDashboardViewModel.addTrainerToAdmin(trainer: trainer)
                                }
                        }
                    }
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Text("Save")
                    .onTapGesture {
                        adminDashboardViewModel.save()
                    }
            }
        }
    }
} 

@Observable @MainActor class CreateHourlyReportSheetViewModel: AuthProtocol {
    var repository: BaseRepository = Repository.shared
    var user: Auth.User?
    var userAccount: UserAccount?
    var userProfile: UserProfile?
    var currentTeam: Team?
    
    var currentList: [TrainerSaleryData] = []
    
    var start: Date = Date().startOfMonth
    var end = Date().endOfMonth
    
    init() {
        inizializeAuth()
    }
    
    func getTrainerData() {
        do {
            let data: [UUID: Int] = try getloadTrainerData()
            var list: [UserProfile: Double] = [:]
            
            try data.forEach { (userAccount: UUID, minutes: Int) in
                if let existAccount = try repository.accountRepository.getAccount(id: userAccount),
                   let userProfile = try repository.userRepository.getUserProfileFromDatabase(userId: existAccount.userId) {
                    
                    let hours = roundMinutesToQuarterHours(minutes: minutes)
                    list[userProfile] = hours
                }
            }
            
            currentList = list.map {
                TrainerSaleryData(fullName: $0.key.fullName, hours: $0.value, hourlyRate: 12.99)
            }
        } catch {
            currentList = []
        }
    }
    
    private func getloadTrainerData() throws -> [UUID: Int] {
        guard let team = currentTeam else { throw TeamError.teamNotFound }
        
        var trainer: [UUID: Int] = [:]
        let termine = try repository.terminRepository.getTeamTermineForDateRange(for: team.id, start: start, end: end)
        try termine.forEach { termin in
            
            let minutes = termin.durationMinutes
            
            let trainerTheyWasThere = try repository.teamRepository.getTrainersForTermineWhenIsConfirmed(terminId: termin.id)
            trainerTheyWasThere.forEach { attendance in
                let trainerId = attendance.userAccountId

                if let existingMinutes = trainer[trainerId] {
                    // Trainer ist bereits in der Liste, addiere die Minuten
                    trainer[trainerId] = existingMinutes + minutes
                } else {
                    // Trainer ist neu, füge ihn mit den Minuten hinzu
                    trainer[trainerId] = minutes
                }
            }
        }
        
        return trainer
    }
    
    private func roundMinutesToQuarterHours(minutes: Int) -> Double {
        let totalHours = Double(minutes) / 60.0
        let quarterHours = round(totalHours * 4.0) / 4.0
        return quarterHours
    }
}

struct CreateHourlyReportSheet: View {
    @State var viewModel = CreateHourlyReportSheetViewModel()
    var body: some View {
        SheetStlye(title: "Create hourly report", detents: [.medium], isLoading: .constant(false)) {
            VStack {
                DatePicker("Startdatum", selection: $viewModel.start, in: ...viewModel.end, displayedComponents: .date)
                    .onChange(of: viewModel.start) { _, _ in
                        viewModel.getTrainerData()
                    }
                
                DatePicker("Enddatum", selection: $viewModel.end, in: viewModel.start...viewModel.end, displayedComponents: .date)
                    .onChange(of: viewModel.end) { _, _ in
                        viewModel.getTrainerData()
                    }
                
                Button("Generate") {
                    viewModel.getTrainerData()
                }
                .buttonStyle(DarkButtonStlye())
                .padding(.bottom, 20)
                 
                if !viewModel.currentList.isEmpty {
                    let page = PDFInfo(image: Image(.appIcon), list: viewModel.currentList, createdAt: Date())
                    ShareLinkPDFView(page: page)
                } else {
                    ContentUnavailableView("No Confirmed Coaches found", systemImage: "figure.basketball", description: Text("The hourly report cannot be created"))
                }
            }
            .padding(.horizontal, 20)
        }
    }
}

#Preview {
    VStack {
        Button("Generate") {
            
        }
        .buttonStyle(DarkButtonStlye())
        ContentUnavailableView("No Confirmed Coaches found", systemImage: "figure.basketball", description: Text("The hourly report cannot be created"))
    }
}

#Preview {
    @Previewable let cal = Calendar.current
    @Previewable @State var isSheet = true
    @Previewable @State var start: Date = Date().startOfMonth
    @Previewable @State var end = Date().endOfMonth
    AdminDashboardView()
        .sheet(isPresented: $isSheet) {
            CreateHourlyReportSheet()
        }
}

extension Date {
    var startOfMonth: Date {
       let calendar = Calendar(identifier: .gregorian)
       let components = calendar.dateComponents([.year, .month], from: self)

       return  calendar.date(from: components)!
   }
    
    var endOfMonth: Date {
        var components = DateComponents()
        components.month = 1
        components.second = -1
        return Calendar(identifier: .gregorian).date(byAdding: components, to: startOfMonth)!
    }
}
