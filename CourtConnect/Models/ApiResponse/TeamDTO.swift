//
//  TeamDTO.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 27.01.25.
//
import Foundation

struct TeamDTO: DTOProtocol {
    var id: UUID
    var teamName: String
    var createdBy: String
    var headcoach: String
    var joinCode: String
    var email: String
    var createdAt: Date
    var updatedAt: Date
    var deletedAt: Date?
    
    init(id: UUID = UUID(), teamName: String, createdBy: String, headcoach: String, joinCode: String, email: String, createdAt: Date, updatedAt: Date, deletedAt: Date? = nil) {
        self.id = id
        self.teamName = teamName
        self.createdBy = createdBy
        self.headcoach = headcoach
        self.joinCode = joinCode
        self.email = email
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
    }
    
    func toModel() -> Team {
        return Team(id: id, teamName: teamName, createdBy: createdBy, headcoach: headcoach, joinCode: joinCode, email: email, createdAt: createdAt, updatedAt: updatedAt, deletedAt: deletedAt)
    }
}
