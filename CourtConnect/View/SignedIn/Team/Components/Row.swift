//
//  Row.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 13.02.25.
//
import SwiftUI

struct Row<Content: View>: View {
    let title: LocalizedStringKey
    @ViewBuilder var content: () -> Content
    var body: some View {
        VStack(alignment: .leading) {
            UpperCasedheadline(text: title)
                .padding(.horizontal)
            
            content()
        }
    }
}

#Preview {
    ScrollView {
        Grid(horizontalSpacing: 16, verticalSpacing: 16) {
            GridRow {
                CardIcon(text: "Add Document", systemName: "doc.badge.plus")
                CardIcon(text: "Plan appointment", systemName: "calendar.badge.plus")
            }
            GridRow {
                CardIcon(text: "Show Join QR Code", systemName: "qrcode.viewfinder")
                CardIcon(text: "Show Absenses", systemName: "person.crop.circle.badge.clock")
            }
        }.padding(50)
    }
    .appBackground()
}
