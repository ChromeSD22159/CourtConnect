//
//  CardIcon.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 14.02.25.
//
import SwiftUI

struct CardIcon: View {
    let screenWidth = UIScreen.main.bounds.width
    let text: LocalizedStringKey
    let systemName: String
    
    var body: some View {
        let width = (screenWidth / 2) - (16 * 1.5)
        ZStack {
            LinearGradient(
                stops: [
                    Gradient.Stop(color: Theme.headline, location: 0.00),
                    Gradient.Stop(color: Theme.headlineReversed, location: 1.00)
                ],
                startPoint: UnitPoint(x: 1, y: 0),
                endPoint: UnitPoint(x: 0, y: 1)
            )
            .opacity(0.9)
            .blur(radius: 10)
            
            RoundedRectangle(cornerRadius: 35)
                .inset(by: 1)
                .stroke(
                    LinearGradient(
                        stops: [
                            Gradient.Stop(color: .white.opacity(0.4), location: 0.00),
                            Gradient.Stop(color: .white.opacity(0.6), location: 1.00)
                        ],
                        startPoint: UnitPoint(x: 1, y: 0),
                        endPoint: UnitPoint(x: 0, y: 1)
                    ).opacity(0.8),
                    lineWidth: 2
                )
                .stroke(
                    LinearGradient(
                        stops: [
                            Gradient.Stop(color: .white.opacity(0.4), location: 0.00),
                            Gradient.Stop(color: .white.opacity(0.2), location: 1.00)
                        ],
                        startPoint: UnitPoint(x: 0, y: 1),
                        endPoint: UnitPoint(x: 1, y: 0)
                    ),
                    lineWidth: 2
                )
            
            VStack(spacing: 16) {
                Image(systemName: systemName)
                    .font(.largeTitle)
                
                Text(text)
                    .lineLimit(2, reservesSpace: true)
                    .font(.callout.bold())
            }
            .foregroundStyle(.white)
        }
        .frame(width: width, height: width)
        .borderRadius(35)
    }
}
