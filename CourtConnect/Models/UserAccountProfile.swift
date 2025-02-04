//
//  UserAccountProfile.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 04.02.25.
//
import Foundation

struct UserAccountProfile: Hashable {
    let id: UUID = UUID()
    let userAccount: UserAccount
    let userProfile: UserProfile
}
