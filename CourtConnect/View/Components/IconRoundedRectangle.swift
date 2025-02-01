//
//  IconRoundedRectangle.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 01.02.25.
//
import SwiftUI

struct IconRoundedRectangle: View {
    let systemName: String
    let font: Font = .system(size: 15)
    let foreground: Color = Theme.myGray
    let background: some ShapeStyle = Material.ultraThinMaterial
    var body: some View {
        Image(systemName: systemName)
            .font(font)
            .padding(10)
            .foregroundStyle(foreground)
            .background {
                RoundedRectangle(cornerRadius: 15)
                    .fill(background)
            }
    }
}
