//
//  UserRole.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 12.01.25.
//
import SwiftUI

enum UserRole: String, CaseIterable, Codable, Identifiable {
    case player = "Player"
    case coach = "Trainer" 
    case admin = "Super-Admin"
    
    var id: Self {
        self
    }
    
    static var registerRoles: [UserRole] {
        [.player, .coach]
    }
    
    var localized: LocalizedStringKey {
        switch self {
        case .player: return "Player"
        case .coach: return "Coach"
        case .admin: return "Super-Admin"
        }
    }
}
