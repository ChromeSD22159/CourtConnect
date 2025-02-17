//
//  MockUser.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 24.01.25.
//
import Foundation

struct MockUser { 
    static let myUserProfile = UserProfile(userId: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!, firstName: "Max", lastName: "Musterman", birthday: "22.11.1986")
    static let myUserAccount = UserAccount(userId: myUserProfile.id, teamId: teamId, position: "Position", role: "Spieler", displayName: "Spieler", createdAt: Date(), updatedAt: Date())
    
    static let userList = [
        myUserProfile,
        UserProfile(userId: UUID(uuidString: "00000000-0000-0000-0000-000000000010")!, firstName: "Sabina", lastName: "Hodel", birthday: "21.06.1995"),
        UserProfile(userId: UUID(uuidString: "00000000-0000-0000-0000-000000000020")!, firstName: "Nico", lastName: "Kohler", birthday: "08.01.2010")
    ]
    
    static let userAccountList = [
        myUserAccount,
        UserAccount(userId: userList[1].id, teamId: teamId, position: "Position", role: "Trainer", displayName: "Spieler", createdAt: Date(), updatedAt: Date()),
        UserAccount(userId: userList[2].id, teamId: teamId, position: "Position", role: "Spieler", displayName: "Spieler", createdAt: Date(), updatedAt: Date())
    ]
    
    static let teamId = UUID(uuidString: "99580a57-81dc-4f4d-adde-0e871505c679")!
} 
