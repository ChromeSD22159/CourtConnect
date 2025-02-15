//
//  NoAppointmentAvailableView.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 16.02.25.
// 
import SwiftUI
 
struct NoAppointmentAvailableView: View {
    var body: some View {
        ContentUnavailableView("No appointments", systemImage: "calendar", description: Text("There are no appointments to insert statistics for the players."))
    }
}
