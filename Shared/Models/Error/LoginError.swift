//
//  LoginError.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 25.01.25.
// 
import Foundation
import SwiftUICore
 
enum LoginError: Error, LocalizedError {
    case emailIsEmpty
    case passwordIsEmpty

    var errorDescription: LocalizedStringKey? {
        switch self {
        case .emailIsEmpty: return "The email field cannot be empty."
        case .passwordIsEmpty: return "The password field cannot be empty."
        }
    }
} 
