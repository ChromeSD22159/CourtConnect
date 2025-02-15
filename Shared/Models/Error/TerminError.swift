//
//  TerminError.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 02.02.25.
//
import Foundation
import SwiftUICore

enum TerminError: Error, LocalizedError {
    case missingTitle
    case missingPlace
    case missingInformation
    case missingTeamId
    case invalidDuration // Example: Add more cases as needed
    case invalidDate
    case teamNotFound
    case other(Error) // For wrapping other errors

    var errorDescription: LocalizedStringKey? {
        switch self {
        case .missingTitle: return "Title is required."
        case .missingPlace: return "Place is required."
        case .missingInformation: return "Information is required."
        case .missingTeamId: return "TeamId is invalid"
        case .invalidDuration: return "Duration is invalid."
        case .invalidDate: return "Date is invalid."
        case .teamNotFound: return "Team not found."
        case .other(let error): return LocalizedStringKey(error.localizedDescription)
        }
    }
}
