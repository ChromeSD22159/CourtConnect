//
//  TeamMemberProfile.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 07.02.25.
//
import SwiftUI

struct TeamMemberProfile: Identifiable {
    var id: UUID = UUID()
    var userProfile: UserProfile
    var teamMember: TeamMember 
}
