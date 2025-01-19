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
    
    @State var notificationManager = NotificationService()
    
    var body: some View {
        TabView {
            Tab("Home", systemImage: "house.fill") {
                DashboardView(userViewModel: userViewModel)
            }
            Tab("Settings", systemImage: "gear") {
                SettingsView(userViewModel: userViewModel)
            }
        }
        .sheet(isPresented: $userViewModel.showOnBoarding, content: {
            UserProfileEditView(userViewModel: userViewModel)
        })
        .onAppear{
            userViewModel.setUserOnline()
            userViewModel.startListeners()
            
        }
        .task {
            if !notificationManager.hasPermission {
                await notificationManager.request()
            }
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase == .active {
                userViewModel.setUserOnline()
            } else if newPhase == .background {
                userViewModel.setUserOffline()
            }
        }
    }
} 
 
#Preview {
    @Previewable @State var vm = SharedUserViewModel(repository: Repository(type: .preview))
    MainNavigationView(userViewModel: vm)
        .onAppear {
            vm.user = MockUser.myUser
        }
}
