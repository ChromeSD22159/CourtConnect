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
        NavigationStack {
            TabView {
                Tab("house.fill", systemImage: "home") {
                    DashboardView(userViewModel: userViewModel)
                }
            }
        }
    }
} 
 
#Preview {
    let repo = Repository(type: .preview)
    MainNavigationView(userViewModel: SharedUserViewModel(repository: repo))
}
