//
//  IconCard.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 30.01.25.
//
import SwiftUI

struct IconCard: View {
    let systemName: String
    let title: LocalizedStringKey
    let backgroundColor: Color?
    let backgroundMaterial: Material?
    let badge: Int?
    
    init(systemName: String, title: LocalizedStringKey, background: Color, badge: Int? = nil) {
        self.systemName = systemName
        self.title = title
        self.backgroundColor = background
        self.backgroundMaterial = nil
        self.badge = badge
    }
    
    init(systemName: String, title: LocalizedStringKey, background: Material, badge: Int? = nil) {
        self.systemName = systemName
        self.title = title
        self.backgroundColor = nil
        self.backgroundMaterial = background
        self.badge = badge
    }
    
    var body: some View {
        VStack {
            RoundedIcon(systemName: systemName)
                .badgeOverlay(count: badge)
            
            Text(title)
                .foregroundStyle(Theme.text)
                .font(.footnote)
        }
        .padding(30)
        .background {
            if let material = backgroundMaterial {
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.clear) 
                    .background(material)
            } else if let color = backgroundColor {
                RoundedRectangle(cornerRadius: 15)
                    .fill(color)
            } else {
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.white)
            }
        }
        .borderRadius(15)
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
