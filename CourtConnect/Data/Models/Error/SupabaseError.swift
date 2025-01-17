//
//  SupabaseError.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 17.01.25.
//

import Foundation
 
enum SupabaseError: Error, LocalizedError {
    case unexpectedError(message: String)
}
