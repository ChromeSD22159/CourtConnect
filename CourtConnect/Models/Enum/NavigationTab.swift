//
//  NavigationTab.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 28.01.25.
// 
import SwiftUI
 
enum NavigationTab: Identifiable, CaseIterable {
    case home
    case team
    case player
    case settings
    
    var id: Self { self }
    
    var name: LocalizedStringKey {
        switch self {
        case .home: return "Home"
        case .team: return "Team"
        case .player: return "Player"
        case .settings: return "Settings"
        }
    }
    
    var images: String {
        switch self {
        case .home: return "house.fill"
        case .team: return "figure.basketball"
        case .player: return "basketball.fill"
        case .settings: return "gear"
        }
    }
}
