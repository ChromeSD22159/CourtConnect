//
//  RoundedFilledButtonStlye.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 25.01.25.
//
import SwiftUI

struct RoundedFilledButtonStlye: ButtonStyle {
    let color: Color
    init (color: Color = Theme.lightOrange) {
        self.color = color
    }
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(7)
            .foregroundStyle(.white)
            .background(color)
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
