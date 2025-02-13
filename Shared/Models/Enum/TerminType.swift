//
//  TerminType.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 01.02.25.
//
import SwiftUI
 
enum TerminType: String, CaseIterable, Identifiable {
    case game = "Game"
    case training = "Training"
    case other = "Other"
    
    var displayName: LocalizedStringKey {
        switch self {
        case .game: return "Game"
        case .training: return "Training"
        case .other: return "Other"
        }
    }
    
    static var statistics: [TerminType] {
        [.game, .training]
    }
    
    var localized: LocalizedStringKey {
        switch self {
        case .game: "Game"
        case .training: "Training"
        case .other: "Other"
        }
    }
    
    var id: String { rawValue }
}
