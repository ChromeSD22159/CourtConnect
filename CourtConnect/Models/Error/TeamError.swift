//
//  TeamError.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 31.01.25.
//
import Foundation

enum TeamError: Error, LocalizedError {
    case noTeamFoundwithThisJoinCode
    
    var errorDescription: String? {
        switch self {
        case .noTeamFoundwithThisJoinCode: return "No Team Found with the provided Join Code."
        }
    }
}
