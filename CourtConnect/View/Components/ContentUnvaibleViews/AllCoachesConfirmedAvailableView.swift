//
//  AllCoachesConfirmedAvailableView.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 16.02.25.
//
import SwiftUI

struct AllCoachesConfirmedAvailableView: View {
    var body: some View {
        ContentUnavailableView(
            "All coaches confirmed",
            systemImage: "checkmark.circle.fill",
            description: Text("All coaches have already confirmed for this appointment.")
        )
    }
}
