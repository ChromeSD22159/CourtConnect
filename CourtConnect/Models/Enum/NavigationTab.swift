//
//  NavigationTab.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 28.01.25.
// 
import SwiftUI
 
enum NavigationTab: Identifiable, CaseIterable {
    case home
    case settings
    
    var id: Self { self }
    
    var name: LocalizedStringKey {
        switch self {
        case .home: return "Home"
        case .settings: return "Settings"
        }
    }
    
    var images: String {
        switch self {
        case .home: return "house.fill"
        case .settings: return "gear"
        }
    }
}
