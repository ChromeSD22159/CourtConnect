//
//  Row.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 13.02.25.
//
import SwiftUI

struct Row<Content: View>: View {
    let title: String
    @ViewBuilder var content: () -> Content
    var body: some View {
        VStack(alignment: .leading) {
            UpperCasedheadline(text: .init(title))
                .padding(.horizontal)
            
            content()
        }
    }
}
