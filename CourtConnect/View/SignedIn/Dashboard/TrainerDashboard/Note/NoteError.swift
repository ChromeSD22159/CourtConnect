//
//  NoteError.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 19.02.25.
//
import Foundation

enum NoteError: Error, LocalizedError {
    case titleToTooShort
    case dateNotInFuture
    case descriptionTooShort
    
    var errorDescription: String? {
        switch self {
        case .descriptionTooShort: return "The description is too short."
        case .dateNotInFuture: return "The date is in the past. Please choose a date in the future."
        case .titleToTooShort: return "The title is too short."
        }
    }
}
