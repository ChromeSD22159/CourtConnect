//
//  UpperCasedheadline.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 06.02.25.
//
import SwiftUI

struct UpperCasedheadline: View {
    let text: String
    let foregroundColor: Color
    
    init(text: String, foregroundColor: Color = Theme.myGray) {
        self.text = text
        self.foregroundColor = foregroundColor
    }
    
    var body: some View {
        Text(text.uppercased())
            .font(.footnote)
            .foregroundStyle(foregroundColor)
    }
}
