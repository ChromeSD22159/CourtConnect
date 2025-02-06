//
//  ShowModeTextButton.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 06.02.25.
//
import SwiftUI

struct ShowModeTextButton: View {
    @Binding var showAll: Bool
    
    let foreground: Color
    
    init(showAll: Binding<Bool>, foreground: Color = Theme.headline) {
        self._showAll = showAll
        self.foreground = foreground
    }
    
    var body: some View {
        Text(showAll ? "Show less" : "Show more")
            .foregroundStyle(foreground)
            .onTapGesture {
                withAnimation {
                    showAll.toggle()
                }
            }
    }
}
