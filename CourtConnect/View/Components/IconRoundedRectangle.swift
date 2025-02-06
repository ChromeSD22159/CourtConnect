//
//  IconRoundedRectangle.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 01.02.25.
//
import SwiftUI

struct IconRoundedRectangle: View {
    let systemName: String
    var font: Font
    var foreground: Color = Theme.myGray
    let backgroundMaterial: Material?
    let backgroundColor: Color?
    let onClick: () -> Void
    
    init(systemName: String, font: Font = .system(size: 15), foreground: Color = Theme.myGray , background: Material = Material.ultraThinMaterial, onClick: @escaping () -> Void = {}) {
        self.systemName = systemName
        self.font = font
        self.foreground = foreground
        self.backgroundMaterial = background
        self.backgroundColor = nil
        self.onClick = onClick
    }
    
    init(systemName: String, font: Font = .system(size: 15), foreground: Color = Theme.myGray , background: Color = Theme.lightOrange, onClick: @escaping () -> Void = {}) {
        self.systemName = systemName
        self.font = font
        self.foreground = foreground
        self.backgroundColor = background
        self.backgroundMaterial = nil
        self.onClick = onClick
    }
    
    var body: some View {
        Image(systemName: systemName)
            .font(font)
            .padding(10)
            .foregroundStyle(foreground)
            .background {
                if let backgroundColor = backgroundColor {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(backgroundColor)
                }
                if let backgroundMaterial = backgroundMaterial {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(backgroundMaterial)
                }
            }
            .onTapGesture {
                onClick()
            }
    }
}
