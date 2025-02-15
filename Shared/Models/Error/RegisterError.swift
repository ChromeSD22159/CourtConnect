//
//  RegisterError.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 25.01.25.
//
import Foundation
import SwiftUICore

enum RegisterError: Error, LocalizedError {
    case emailIsEmpty
    case passwordIsEmpty
    case repeatPasswordIsEmpty
    case passwordsNotTheSame
    var errorDescription: LocalizedStringKey? {
        switch self {
        case .emailIsEmpty: return "The email field cannot be empty."
        case .passwordIsEmpty: return "The password field cannot be empty."
        case .repeatPasswordIsEmpty: return "The repeat password field cannot be empty."
        case .passwordsNotTheSame: return "The passwords do not match. Please make sure both passwords are the same."
        }
    }
}
