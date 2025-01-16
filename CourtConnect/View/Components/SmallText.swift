//
//  SmallText.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 11.01.25.
//
import SwiftUI

struct SmallText: View {
    let text: String
    
    init(_ text: String) {
        self.text = text
    }
    
    var body: some View {
        Text(text)
            .font(.caption)
    }
}
