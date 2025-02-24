//
//  NoConfirmedCoaches.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 21.02.25.
//
import SwiftUI

struct NoConfirmedCoaches: View {
    var body: some View {
        ContentUnavailableView("No Confirmed Coaches found", systemImage: "figure.basketball", description: Text("The hourly report cannot be created"))
    }
}
