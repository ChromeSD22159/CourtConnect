//
//  InputValidationError.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 30.01.25.
//
import Foundation

enum InputValidationError: Error, LocalizedError {
    case emailTooSmall, teamNameTooSmall, headcoachTooSmall
    
    var errorDescription: String? {
        switch self {
        case .emailTooSmall: return "The email address must be at least 6 characters long."
        case .teamNameTooSmall: return "The team name must be at least 6 characters long."
        case .headcoachTooSmall: return "The head coach's name must be at least 5 characters long."
        }
    }
}
