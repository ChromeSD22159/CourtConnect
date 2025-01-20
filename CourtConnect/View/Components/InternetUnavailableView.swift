//
//  InternetUnavailableView.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 20.01.25.
//
import SwiftUI

struct InternetUnavailableView: View {
    var body: some View {
        ContentUnavailableView {
            Label("No Connection", systemImage: "wifi.slash")
        } description: {
            Text("Try checking the Network Connection.")
        }
    }
}

#Preview {
    InternetUnavailableView()
}
