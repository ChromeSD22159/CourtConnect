//
//  NavigationStackTint.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 29.01.25.
//
import SwiftUI

extension View {
    func navigationStackTint() -> some View {
         modifier(NavigationStackTint())
    }
}

struct NavigationStackTint: ViewModifier {
    func body(content: Content) -> some View {
        content
            .tint(Theme.headline)
    }
}

#Preview("Light") {
    NavigationStack {
        NavigationLink {
           Text("Detail")
        } label: {
            Text("label")
        }
    }
    .navigationStackTint() 
    .preferredColorScheme(.light)
}

#Preview("Dark") {
    NavigationStack {
        NavigationLink {
           Text("Detail")
        } label: {
            Text("label")
        }
    }
    .navigationStackTint()
    .preferredColorScheme(.dark)
}
