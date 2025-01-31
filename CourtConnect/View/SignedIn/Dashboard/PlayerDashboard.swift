//
//  PlayerDashboard.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 27.01.25.
//
import SwiftUI

@Observable class PlayerDashboardViewModel {
    
}

struct PlayerDashboard: View {
    @ObservedObject var userViewModel: SharedUserViewModel
    @ObservedObject var dashBoardViewModel: DashBoardViewModel
    var body: some View {
        VStack {
            Text(userViewModel.userProfile?.firstName ?? "")
            
            Button("Delete UserAccount Account") {
                Task {
                    do {
                        try await dashBoardViewModel.deleteUserAccount(for: userViewModel.currentAccount)
                        try userViewModel.setRandomAccount()
                    } catch {
                        print(error)
                    }
                }
            }
        }
        .navigationTitle("Trainer")
    }
}
