//
//  TrainerDashboard.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 27.01.25.
//
import SwiftUI

struct TrainerDashboard: View {
    @ObservedObject var userViewModel: SharedUserViewModel
    @ObservedObject var userAccountViewModel: UserAccountViewModel
    var body: some View {
        VStack {
            Text(userViewModel.userProfile?.firstName ?? "")
        }
        .navigationTitle("Trainer")
    }
} 
