//
//  DocumentError.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 11.02.25.
//
import Foundation
import SwiftUICore
 
enum DocumentError: Error, LocalizedError {
    case fileNameToShot
    case descriptionToShot
    
    var errorDescription: LocalizedStringKey? {
        switch self {
        case .fileNameToShot: return "The Filename is less them 5 characters"
        case .descriptionToShot: return "The Description is less them 5 characters"
        }
    }
}
