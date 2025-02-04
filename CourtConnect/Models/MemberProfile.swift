//
//  MemberProfile.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 04.02.25.
// 
import Foundation
 
struct MemberProfile: Identifiable {
    var id: UUID = UUID()
    var firstName: String
    var lastName: String
    var position: String?
    var shirtNumber: Int?
    var fullName: String {
        firstName + " " + lastName
    }
    
    var avgFouls: Int
    var avgTwo: Int
    var avgtree: Int
    var avgPoints: Int
}
