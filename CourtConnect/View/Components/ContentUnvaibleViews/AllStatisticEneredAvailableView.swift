//
//  AllStatisticEneredAvailableView.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 16.02.25.
//
import SwiftUI

struct AllStatisticEneredAvailableView: View {
    var body: some View {
        ContentUnavailableView(
            "All statistics entered",
            systemImage: "checkmark.circle.fill", // Oder ein anderes passendes Symbol
            description: Text("The statistics have already been entered for all players.")
        )
    }
}
