//
//  TeamUnavailableView.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 03.02.25.
//
import SwiftUI

struct TeamUnavailableView: View {
    var body: some View {
        ContentUnavailableView {
            Label("No Team", systemImage: "person.3.fill")
        } description: {
            Text("The selected user account is not part of a team. Join a team to get started.")
        }
    }
}

#Preview {
    TeamUnavailableView() 
}
