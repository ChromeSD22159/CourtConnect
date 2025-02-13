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
            Label("No team coach", systemImage: "calendar")
        } description: {
            Text("No team coach currently found.")
        }
    }
}
