//
//  NoDocumentAVailableView.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 16.02.25.
//
import SwiftUI

struct NoDocumentAvailableView: View {
    var body: some View {
        ContentUnavailableView("No documents found", systemImage: "text.document", description: Text("Your team has no documents."))
    }
}
