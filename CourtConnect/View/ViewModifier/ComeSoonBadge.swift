//
//  ComeSoonBadge.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 10.02.25.
//
import SwiftUI

extension View {
    func comeSoonBadge() -> some View {
        modifier(ComeSoonBadge())
    }
    
    func betaBadge() -> some View {
        modifier(BetaBadge())
    }
 
    func comeSoon() -> some View {
        modifier(ComeSoon())
    }
}
 
struct ComeSoon: ViewModifier {
    func body(content: Content) -> some View {
        content 
            .opacity(0.5)
            .disabled(true)
    }
}

struct ComeSoonBadge: ViewModifier {
    func body(content: Content) -> some View {
        content
            .overlay(alignment: .topLeading) {
                Text("Soon..")
                    .padding(5)
                    .foregroundStyle(Theme.white)
                    .background(Theme.headline)
                    .clipShape(RoundedRectangle(cornerRadius: 7))
                    .borderRadius(7)
                    .rotationEffect(Angle(degrees: -15))
            }
    }
}

struct BetaBadge: ViewModifier {
    func body(content: Content) -> some View {
        content
            .overlay(alignment: .topLeading) {
                Text("Beta")
                    .padding(5)
                    .foregroundStyle(Theme.white)
                    .background(Theme.headline)
                    .clipShape(RoundedRectangle(cornerRadius: 7))
                    .borderRadius(7)
                    .rotationEffect(Angle(degrees: -15))
            }
    }
}
