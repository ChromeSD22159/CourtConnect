//
//  RequestUser.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 30.01.25.
// 
import Foundation
 
struct RequestUser: Identifiable {
    let id: UUID
    let userAccount: UserAccount
    let userProfile: UserProfile
    
    init(id: UUID = UUID(), userAccount: UserAccount, userProfile: UserProfile) {
        self.id = id
        self.userAccount = userAccount
        self.userProfile = userProfile
    }
} 
