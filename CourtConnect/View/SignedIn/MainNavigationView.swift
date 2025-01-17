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
    let repo = Repository(type: .preview)
    MainNavigationView(userViewModel: SharedUserViewModel(repository: repo))
}
