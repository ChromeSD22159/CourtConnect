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
            Label("Keine Termine", systemImage: "calendar")
        } description: {
            Text("Es sind derzeit keine Termine geplant.")
        }
    }
}
