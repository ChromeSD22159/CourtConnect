//
//  ContentView.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 11.01.25.
//

import SwiftUI

struct MainNavigationView: View {
    @ObservedObject var userViewModel: SharedUserViewModel
    
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
    }
} 
 
#Preview {
    let repo = Repository(type: .preview)
    MainNavigationView(userViewModel: SharedUserViewModel(repository: repo))
}
