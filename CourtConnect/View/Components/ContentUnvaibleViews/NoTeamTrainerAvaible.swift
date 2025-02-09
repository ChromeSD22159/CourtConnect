//
//  NoTeamTrainerAvaible.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 09.02.25.
//
import SwiftUI

struct NoTeamTrainerAvaible: View {
    var body: some View {
        ContentUnavailableView {
            Label("No Team Trainer", systemImage: "calendar")
        } description: {
            Text("No Team Trainer currently found.")
        }
    }
}
