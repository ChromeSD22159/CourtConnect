//
//  TeamError.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 31.01.25.
//
import Foundation

enum TeamError: Error, LocalizedError {
    case userHasNoTeam
    case teamNotFound
    case noTeamFoundwithThisJoinCode
    
    var errorDescription: String? {
        switch self {
        case .userHasNoTeam: return "User has no Team."
        case .teamNotFound: return "Team not found."
        case .noTeamFoundwithThisJoinCode: return "No Team Found with the provided Join Code."
        }
    }
}
