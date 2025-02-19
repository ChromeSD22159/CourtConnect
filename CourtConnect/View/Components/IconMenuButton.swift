//
//  IconMenuButton.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 29.01.25.
//
import SwiftUI

struct IconMenuButton<Content: View>: View {
    let icon: String
    let description: LocalizedStringKey
    @ViewBuilder var content: () -> Content
    var body: some View {
        Menu {
            Text(description)
            content()
        } label: {
            Image(systemName: icon)
                .foregroundStyle(Theme.headline)
        }
    }
}

#Preview {
    Image(systemName: "pencil.circle.fill")
        .padding(12)
        .background(
            Circle()
                .fill(.gray)
        )
}
