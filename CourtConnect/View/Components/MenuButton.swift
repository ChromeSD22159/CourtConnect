//
//  Transition.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 22.01.25.
//
import SwiftUI

struct MenuButton<Content: View>: View {
    
    let icon: String
    
    @ViewBuilder var content: Content
    
    var body: some View {
        Menu {
            content
        } label: {
            Image(systemName: icon)
        }
    }
}

#Preview {
    NavigationStack {
        ZStack {
            
        }
        .toolbar {
            ToolbarItem(placement: .navigation) {
                MenuButton(icon: "figure") {
                    Button("Player") {}
                    
                    Button("Trainer") {}
                }
                .foregroundStyle(.red)
            }
        }
    }
}
