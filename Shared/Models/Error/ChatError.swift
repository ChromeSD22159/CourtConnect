//
//  ChatError.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 11.02.25.
//
import Foundation

enum ChatError: Error, LocalizedError {
    case whileSendindToServer
    
    var errorDescription: String? {
        switch self {
        case .whileSendindToServer: return "whileSendindToServer"
        }
    }
}
