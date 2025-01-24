//
//  MockUser.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 24.01.25.
//
import Foundation

struct MockUser { 
    static let myUserProfile = UserProfile(userId: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!.uuidString, firstName: "Frederik", lastName: "Kohler", roleString: UserRole.player.rawValue, birthday: "22.11.1986")
    
    static let userList = [
        myUserProfile,
        UserProfile(userId: UUID(uuidString: "00000000-0000-0000-0000-000000000010")!.uuidString, firstName: "Sabina", lastName: "Hodel", roleString: UserRole.player.rawValue, birthday: "21.06.1995"),
        UserProfile(userId: UUID(uuidString: "00000000-0000-0000-0000-000000000020")!.uuidString, firstName: "Nico", lastName: "Kohler", roleString: UserRole.player.rawValue, birthday: "08.01.2010")
    ]
}
