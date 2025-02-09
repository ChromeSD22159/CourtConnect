//
//  NoTeamMemberAvaible.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 09.02.25.
// 
import SwiftUI

struct NoTeamMemberAvaible: View {
    var body: some View {
        ContentUnavailableView {
            Label("No Team Member", systemImage: "calendar")
        } description: {
            Text("No Team Member currently found.")
        }
    }
}
