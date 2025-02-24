//
//  AdminDashboardView.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 10.02.25.
//
import SwiftUI
import Auth

struct AdminDashboardView: View {
    @Environment(\.dismiss) var dismiss
    @State var adminDashboardViewModel: AdminDashboardViewModel = AdminDashboardViewModel()
    @State var isRateSheet = false
    var body: some View {
        AnimationBackgroundChange {
            List {
                ListInfomationSection(text: "Here you can manage the team admins, change the team names or delete the team.")
                
                Section {
                    VStack(alignment: .leading) {
                        Label("Create report", systemImage: "plus")
                            .onTapGesture {
                                isRateSheet.toggle()
                            }
                            .sheet(isPresented: $isRateSheet) {
                                if !adminDashboardViewModel.coachHourlyRate.isEmpty, let rate = Double(adminDashboardViewModel.coachHourlyRate) {
                                    CreateHourlyReportSheet(hourlyRate: rate)
                                }
                                
                            }
                    }
                } header: {
                    UpperCasedheadline(text: "Trainer Hour Report")
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
                } header: {
                    UpperCasedheadline(text: "Change Team name")
                }
                .blurrylistRowBackground()
                
                Section {
                    TextField("Coach hourly rate", text: $adminDashboardViewModel.coachHourlyRate, prompt: Text("Coach hourly rate e.g. 9.99"))
                } header: {
                    UpperCasedheadline(text: "Coach hourly rate")
                }
                .blurrylistRowBackground() 
                
                Section { // addStatisticConfirmedOnly
                    Toggle(isOn: $adminDashboardViewModel.addStatisticConfirmedOnly) {
                        Text("Insert statistics only for confirmed players")
                    }
                } header: {
                    UpperCasedheadline(text: "Team settings")
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
        .messagePopover()
        .navigationTitle(title: "Admin Dashboard")
        .listBackgroundAnimated() 
        .sheet(isPresented: $adminDashboardViewModel.isAddAdminSheet) {
            SheetStlye(title: "Add Admin", detents: [.medium, .large], isLoading: .constant(false)) {
                if adminDashboardViewModel.teamTrainer.isEmpty {
                    NoTeamMemberAvaible()
                } else {
                    ForEach(adminDashboardViewModel.teamTrainer) { trainer in
                        Button {
                            adminDashboardViewModel.addTrainerToAdmin(trainer: trainer)
                        } label: {
                            HStack {
                                Label(trainer.userProfile.fullName, systemImage: "plus")
                                Spacer()
                            }
                            .padding()
                        }
                    }
                }
            }
        }
        .onDisappear {
            adminDashboardViewModel.save()
        }
    }
}  

#Preview {
    @Previewable let cal = Calendar.current
    @Previewable @State var isSheet = true
    @Previewable @State var start: Date = Date().startOfMonth
    @Previewable @State var end = Date().endOfMonth
    AdminDashboardView()
        .sheet(isPresented: $isSheet) {
            CreateHourlyReportSheet(hourlyRate: 9.00)
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
