//
//  Team.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 24.01.25.
//
import SwiftData
import Foundation

@Model class Team: ModelProtocol { 
    @Attribute(.unique) var id: UUID
    var teamName: String
    var headcoach: String
    var joinCode: String
    var email: String
    var createdByUserAccountId: UUID
    var createdAt: Date
    var updatedAt: Date
    var deletedAt: Date?
    
    init(id: UUID = UUID(), teamName: String, headcoach: String, joinCode: String, email: String, createdByUserAccountId: UUID, createdAt: Date, updatedAt: Date, deletedAt: Date? = nil) {
        self.id = id
        self.teamName = teamName
        self.headcoach = headcoach
        self.joinCode = joinCode
        self.email = email
        self.createdByUserAccountId = createdByUserAccountId
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
    }
    
    func toDTO() -> TeamDTO {
        return TeamDTO(id: id, teamName: teamName, headcoach: headcoach, joinCode: joinCode, email: email, createdByUserAccountId: createdByUserAccountId, createdAt: createdAt, updatedAt: updatedAt, deletedAt: deletedAt)
    }
} 
