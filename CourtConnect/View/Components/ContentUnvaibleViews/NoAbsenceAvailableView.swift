//
//  NoAbsenceAvailableView.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 16.02.25.
//
import SwiftUI

struct NoAbsenceAvailableView: View {
    var body: some View {
        ContentUnavailableView("No absence found", systemImage: "figure", description: Text("Your team has no registered future absences."))
    }
}
