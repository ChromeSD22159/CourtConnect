//
//  NotificationError.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 19.02.25.
//
import Foundation

enum NotificationError: Error, LocalizedError {
    case pastDate
    
    var errorDescription: String? {
        switch self {
        case .pastDate: return "Note date is in the past. Not scheduling notification."
        }
    }
}
