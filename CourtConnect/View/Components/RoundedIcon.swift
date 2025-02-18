//
//  RoundedIcon.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 30.01.25.
//
import SwiftUI

struct RoundedIcon: View {
    let systemName : String
    var body: some View {
        Image(systemName: systemName)
            .font(.largeTitle)
            .padding(10)
            .background(Theme.headline)
            .foregroundStyle(.white)
            .borderRadius(10)
    }
}

#Preview {
    RoundedIcon(systemName: "figure")
}
