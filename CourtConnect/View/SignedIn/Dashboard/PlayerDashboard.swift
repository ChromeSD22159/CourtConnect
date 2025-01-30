//
//  PlayerDashboard.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 27.01.25.
//
import SwiftUI

struct PlayerDashboard: View {
    @ObservedObject var userViewModel: SharedUserViewModel 
    var body: some View {
        VStack {
            Text(userViewModel.userProfile?.firstName ?? "")
        }
        .navigationTitle("Trainer")
    }
}
