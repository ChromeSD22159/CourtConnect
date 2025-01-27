//
//  TeamAdminDTO.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 27.01.25.
//
import Foundation 

struct TeamAdminDTO: DTOProtocol {
    var id: UUID
    var teamId: UUID
    var userId: UUID
    var role: String
    var createdAt: Date
    var updatedAt: Date
    var deletedAt: Date?
    
    init(id: UUID = UUID(), teamId: UUID, userId: UUID, role: String, createdAt: Date, updatedAt: Date, deletedAt: Date? = nil) {
        self.id = id
        self.teamId = teamId
        self.userId = userId
        self.role = role
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
    }
    
    func toModel() -> TeamAdmin {
        return TeamAdmin(id: id, teamId: teamId, userId: userId, role: role, createdAt: createdAt, updatedAt: updatedAt, deletedAt: deletedAt)
    }
} 
