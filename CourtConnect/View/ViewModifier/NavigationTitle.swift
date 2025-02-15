//
//  NavigationTitle.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 15.02.25.
//
import SwiftUI

extension View {
    func navigationTitle(title: LocalizedStringKey) -> some View {
        modifier(NavigationTitle(title: title))
    }
}

struct NavigationTitle: ViewModifier {
    let title: LocalizedStringKey
    func body(content: Content) -> some View {
        content
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
    }
}
