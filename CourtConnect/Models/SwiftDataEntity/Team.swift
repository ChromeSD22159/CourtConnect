//
//  Team.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 24.01.25.
//
import SwiftData
import Foundation

@Model class Team: ModelProtocol { 
    var id: UUID
    var teamName: String
    var createdBy: String
    var headcoach: String
    var createdAt: Date
    var updatedAt: Date
    var deletedAt: Date?
    
    init(id: UUID = UUID(), teamName: String, createdBy: String, headcoach: String, createdAt: Date, updatedAt: Date, deletedAt: Date? = nil) {
        self.id = id
        self.teamName = teamName
        self.createdBy = createdBy
        self.headcoach = headcoach
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
    }
    
    func toDTO() -> TeamDTO {
        return TeamDTO(id: id, teamName: teamName, createdBy: createdBy, headcoach: headcoach, createdAt: createdAt, updatedAt: updatedAt, deletedAt: deletedAt)
    }
} 
