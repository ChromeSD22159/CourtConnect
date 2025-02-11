//
//  DocumentError.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 11.02.25.
//
import Foundation
 
enum DocumentError: Error, LocalizedError {
    case fileNameToShot
    
    var errorDescription: String? {
        switch self {
        case .fileNameToShot: return "The Filename ist less tham 5 characters"
        }
    }
}
