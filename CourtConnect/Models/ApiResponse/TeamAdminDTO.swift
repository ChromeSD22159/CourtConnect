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
    var userAccountId: UUID
    var role: String
    var createdAt: Date
    var updatedAt: Date
    var deletedAt: Date?
    
    init(id: UUID = UUID(), teamId: UUID, userAccountId: UUID, role: String, createdAt: Date, updatedAt: Date, deletedAt: Date? = nil) {
        self.id = id
        self.teamId = teamId
        self.userAccountId = userAccountId
        self.role = role
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
    }
    
    func toModel() -> TeamAdmin {
        return TeamAdmin(id: id, teamId: teamId, userAccountId: userAccountId, role: role, createdAt: createdAt, updatedAt: updatedAt, deletedAt: deletedAt)
    }
} 
