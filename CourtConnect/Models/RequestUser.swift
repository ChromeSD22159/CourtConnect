//
//  RequestUser.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 30.01.25.
// 
import Foundation
 
struct RequestUser: Identifiable {
    let id: UUID
    let teamID: UUID
    let userAccount: UserAccount
    let userProfile: UserProfile
    let request: Requests
    
    init(id: UUID = UUID(), teamID: UUID, userAccount: UserAccount, userProfile: UserProfile, request: Requests) {
        self.id = id
        self.teamID = teamID
        self.userAccount = userAccount
        self.userProfile = userProfile
        self.request = request
    }
} 
