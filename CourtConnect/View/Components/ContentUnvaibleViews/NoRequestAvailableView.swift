//
//  NoRequestAvailableView.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 16.02.25.
// 
import SwiftUI

struct NoRequestAvailableView: View {
    var body: some View {
        ContentUnavailableView("No join requests", systemImage: "figure", description: Text("There is currently no accession request."))
    }
}
