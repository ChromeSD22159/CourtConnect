//
//  RoundedIconTextCard.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 30.01.25.
//
import SwiftUI

struct RoundedIconTextCard: View {
    let icon: String
    let title: LocalizedStringKey
    let description: LocalizedStringKey
    var body: some View {
        HStack {
            RoundedIcon(systemName: icon)
            
            VStack(alignment: .leading) {
                Text(title)
                    .multilineTextAlignment(.leading)
                    .foregroundStyle(Theme.headline)
                
                Text(description)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2, reservesSpace: true)
                    .font(.caption)
                    .foregroundStyle(Theme.text)
            }
         
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Material.ultraThinMaterial)
        .borderRadius(15)
    }
}

#Preview {
    RoundedIconTextCard(icon: "figure", title: "Title", description: "Description")
}
