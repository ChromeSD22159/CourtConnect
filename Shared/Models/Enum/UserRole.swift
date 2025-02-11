//
//  UserRole.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 12.01.25.
//

enum UserRole: String, CaseIterable, Codable, Identifiable {
    case player = "Player"
    case trainer = "Trainer"
    case admin = "Super-Admin"
    
    var id: Self {
        self
    }
    
    static var registerRoles: [UserRole] {
        [.player, .trainer]
    }
}
