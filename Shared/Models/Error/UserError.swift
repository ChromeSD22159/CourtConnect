//
//  UserError.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 23.01.25.
//
 
enum UserError: Error {
    case userIdNotFound
    case signInFailed
    case userAccountNotFound
    case emailIsEmptry
}
