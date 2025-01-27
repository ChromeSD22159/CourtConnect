//
//  AccountDTO.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 23.01.25.
//
import Foundation 

struct UserAccountDTO: DTOProtocol {
    var id: UUID // PK
    var userId: UUID
    var teamId: String
    var position: String
    var role: String
    var displayName: String
    var createdAt: Date
    var updatedAt: Date
    var deletedAt: Date?
    
    init(id: UUID = UUID(), userId: UUID, teamId: String, position: String, role: String, displayName: String, createdAt: Date = Date(), updatedAt: Date = Date(), deletedAt: Date? = nil) {
        self.id = id
        self.userId = userId
        self.teamId = teamId
        self.position = position
        self.role = role
        self.displayName = displayName
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
    }
    
    func toModel() -> UserAccount {
        return UserAccount(id: id, userId: userId, teamId: teamId, position: position, role: role, displayName: displayName, createdAt: createdAt, updatedAt: updatedAt, deletedAt: deletedAt)
    }
} 
