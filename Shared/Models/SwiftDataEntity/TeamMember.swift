//
//  TeamMember.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 27.01.25.
//
import Foundation
import SwiftData

@Model
class TeamMember: ModelProtocol {
    @Attribute(.unique) var id: UUID
    var userAccountId: UUID
    var teamId: UUID
    var shirtNumber: Int?
    var role: String
    var createdAt: Date
    var updatedAt: Date
    var deletedAt: Date?
    
    init(id: UUID = UUID(), userAccountId: UUID, teamId: UUID, shirtNumber: Int? = nil, role: String, createdAt: Date, updatedAt: Date, deletedAt: Date? = nil) {
        self.id = id
        self.userAccountId = userAccountId
        self.teamId = teamId
        self.shirtNumber = shirtNumber
        self.role = role
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
    }
    
    func toDTO() -> TeamMemberDTO {
        return TeamMemberDTO(id: id, userAccountId: userAccountId, teamId: teamId, shirtNumber: shirtNumber, role: role, createdAt: createdAt, updatedAt: updatedAt, deletedAt: deletedAt)
    }
}
