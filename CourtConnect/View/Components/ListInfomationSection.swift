//
//  ListInfomationSection.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 07.02.25.
//
import SwiftUI

struct ListInfomationSection:View {
    let text: LocalizedStringKey
    let foreground: Color
    
    init(text: LocalizedStringKey, foreground: Color = Color.primary) {
        self.text = text
        self.foreground = foreground
    }
    
    var body: some View {
        Section {
            VStack(alignment: .leading) {
                Label("Infomation", systemImage: "info")
                    .symbolVariant(.circle.circle)
                
                Text(text)
                    .font(.footnote)
            }
        }
        .foregroundStyle(foreground)
        .listRowBackground(Color.clear)
    }
}
