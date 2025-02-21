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
