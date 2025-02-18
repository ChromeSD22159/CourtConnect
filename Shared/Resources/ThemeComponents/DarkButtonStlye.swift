//
//  DarkButtonStlye.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 01.02.25.
//
import SwiftUI

struct DarkButtonStlye: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .font(.body.bold())
            .foregroundStyle(.white)
            .background(Theme.darkOrange)
            .borderRadius(15)
    }
} 

#Preview {
    Button("DarkButtonStlye") {
        
    }
    .buttonStyle(DarkButtonStlye())
}
