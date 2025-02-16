//
//  BadgeOverlay.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 16.02.25.
//
import SwiftUI

extension View {
    func badgeOverlay(count: Int?, offset: (xValue: CGFloat, yValue: CGFloat) = (xValue: 15, yValue: -15)) -> some View {
        modifier(BadgeOverlay(count: count, offset: offset))
    }
}

struct BadgeOverlay: ViewModifier {
    let count: Int?
    let offset: (xValue: CGFloat, yValue: CGFloat)
    
    func body(content: Content) -> some View {
        content
            .overlay(alignment: .topTrailing) {
                // swiftlint:disable:next empty_count
                if let count = count, count > 0 {
                    
                    Text(count.formatted(.number))
                        .foregroundStyle(.white)
                        .padding(10)
                        .background(
                            Circle()
                                .fill(Theme.headlineReversed)
                        )
                        .offset(x: offset.xValue, y: offset.yValue)
                }
            }
    }
}
