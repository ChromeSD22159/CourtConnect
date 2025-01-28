//
//  TrainerDashboard.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 27.01.25.
//
import SwiftUI

struct TrainerDashboard: View {
    @ObservedObject var userViewModel: SharedUserViewModel
    @ObservedObject var userAccountViewModel: UserAccountViewModel
    var body: some View {
        VStack(spacing: 15) {
            Card(icon: "figure", title: "Team Erstellen!", description: "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua")
            
            Card(icon: "figure", title: "Team Erstellen!", description: "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua")
        }
        .navigationTitle("Trainer")
    }
}

struct Card: View {
    let icon: String
    let title: String
    let description: String
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.largeTitle)
                .padding(10)
                .background(Theme.darkOrange)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            
            VStack(alignment: .leading) {
                Text(title)
                
                Text(description)
                    .lineLimit(2, reservesSpace: true)
                    .font(.caption)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Material.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .padding(.horizontal)
    }
}

#Preview {
    VStack(spacing: 15) {
        Card(icon: "figure", title: "Team Erstellen!", description: "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua")
        
        Card(icon: "figure", title: "Team Erstellen!", description: "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua")
    }
}
