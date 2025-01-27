//
//  RoundedFilledButtonStlye.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 25.01.25.
//
import SwiftUI

struct RoundedFilledButtonStlye: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(7)
            .foregroundStyle(.white)
            .background(Theme.lightOrange)
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
