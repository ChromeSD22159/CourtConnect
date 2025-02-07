//
//  ListInfomationSection.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 07.02.25.
//
import SwiftUI

struct ListInfomationSection:View {
    let text: LocalizedStringKey
    var body: some View {
        Section {
            VStack(alignment: .leading) {
                Label("Infomation", systemImage: "info")
                    .symbolVariant(.circle.circle)
                
                Text(text)
                    .font(.footnote)
            }
        }
        .foregroundStyle(Theme.myGray)
        .listRowBackground(Color.clear)
    }
}
