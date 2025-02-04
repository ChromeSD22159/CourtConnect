//
//  TermineUnavailableView.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 04.02.25.
//
import SwiftUI

struct TermineUnavailableView: View {
    var body: some View {
        ContentUnavailableView {
            Label("No appointments", systemImage: "calendar")
        } description: {
            Text("No appointments are currently planned.")
        }
    }
}
