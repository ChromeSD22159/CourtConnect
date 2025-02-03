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
    
    var displayName: LocalizedStringKey {
        switch self {
        case .game: return "Game"
        case .training: return "Training"
        }
    }
    
    var id: String { rawValue }
}
