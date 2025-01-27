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
    var id: UUID
    var userId: UUID
    var teamId: UUID
    var createdAt: Date
    var updatedAt: Date
    var deletedAt: Date?
    
    init(id: UUID = UUID(), userId: UUID, teamId: UUID, createdAt: Date, updatedAt: Date, deletedAt: Date? = nil) {
        self.id = id
        self.userId = userId
        self.teamId = teamId
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
    }
    
    func toDTO() -> TeamMemberDTO {
        return TeamMemberDTO(id: id, userId: userId, teamId: teamId, createdAt: createdAt, updatedAt: updatedAt, deletedAt: deletedAt)
    }
}
