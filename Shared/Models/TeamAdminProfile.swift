//
//  TeamAdminProfile.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 10.02.25.
//
import SwiftUI

struct TeamAdminProfile: Identifiable {
    var id: UUID = UUID()
    var userProfile: UserProfile
    var teamAdmin: TeamAdmin
}
