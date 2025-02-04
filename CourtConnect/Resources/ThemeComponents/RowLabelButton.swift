//
//  RowLabelButton.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 04.02.25.
//
import SwiftUI

struct RowLabelButton: View {
    let text: LocalizedStringKey
    let systemImage: String
    let onComplete: () -> Void
    var body: some View {
        HStack {
            Label(text, systemImage: systemImage)
            Spacer()
        }
        .onTapGesture {
            onComplete()
        }
        .padding()
        .background(Material.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 15))
    }
}

#Preview {
    RowLabelButton(text: "Label", systemImage: "trash", onComplete: {})
}
