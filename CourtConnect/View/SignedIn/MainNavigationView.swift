//
//  ContentView.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 11.01.25.
//

import SwiftUI

struct MainNavigationView: View {
    @ObservedObject var userViewModel: SharedUserViewModel
    @Environment(\.scenePhase) var scenePhase
     
    @State var networkMonitorViewModel: NetworkMonitorViewModel = NetworkMonitorViewModel()
    
    var body: some View {
        TabView {
            Tab("Home", systemImage: "house.fill") {
                DashboardView(userViewModel: userViewModel, networkMonitorViewModel: networkMonitorViewModel)
            }
            Tab("Settings", systemImage: "gear") {
                SettingsView(userViewModel: userViewModel, networkMonitorViewModel: networkMonitorViewModel)
            }
        }
        .sheet(isPresented: $userViewModel.showOnBoarding, content: {
            UserProfileEditView(userViewModel: userViewModel)
        })
        .task {
            userViewModel.setUserOnline()
            if await !NotificationService.getAuthStatus() {
                await NotificationService.request()
            }
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            userViewModel.changeOnlineStatus(phase: newPhase)
        }
    }
}
 
#Preview {
    @Previewable @State var vm = SharedUserViewModel(repository: Repository(type: .preview))
    MainNavigationView(userViewModel: vm) 
}
