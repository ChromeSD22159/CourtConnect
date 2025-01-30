//
//  IconCard.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 30.01.25.
//
import SwiftUI

struct IconCard: View {
    let systemName: String
    let title: String
    let backgroundColor: Color?
    let backgroundMaterial: Material?
    
    init(systemName: String, title: String, background: Color) {
        self.systemName = systemName
        self.title = title
        self.backgroundColor = background
        self.backgroundMaterial = nil
    }
    
    init(systemName: String, title: String, background: Material) {
        self.systemName = systemName
        self.title = title
        self.backgroundColor = nil
        self.backgroundMaterial = background
    }
    
    var body: some View {
        VStack {
            RoundedIcon(systemName: "person.fill.questionmark")
            
            Text("Join Requests")
                .foregroundStyle(Theme.text)
                .font(.footnote)
        }
        .padding(30)
        .background {
            if let material = backgroundMaterial {
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.clear) // Fill with clear if you don't want a base color
                    .background(material) // Apply Material as background
            } else if let color = backgroundColor {
                RoundedRectangle(cornerRadius: 15)
                    .fill(color)
            } else {
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.white) // Default background color if none provided
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 15))
    }
}

#Preview {
    SnapScrollView(horizontalSpacing: 16) {
        LazyHStack(spacing: 16) {
            IconCard(systemName: "person.fill.questionmark", title: "Join Requests", background: Material.ultraThinMaterial)
            
            IconCard(systemName: "person.fill.questionmark", title: "Join Requests", background: Theme.headline)
        }
        .frame(height: 150)
    }
}
