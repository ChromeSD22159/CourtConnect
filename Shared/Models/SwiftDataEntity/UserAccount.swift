//
//  Account.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 23.01.25.
//
import SwiftData
import Foundation

@Model
class UserAccount: ModelProtocol, Identifiable { 
    @Attribute(.unique) var id: UUID
    var userId: UUID
    var teamId: UUID?
    var position: String
    var role: String
    var displayName: String
    var createdAt: Date
    var updatedAt: Date
    var deletedAt: Date?
    
    init(id: UUID = UUID(), userId: UUID, teamId: UUID? = nil, position: String, role: String, displayName: String, createdAt: Date, updatedAt: Date, deletedAt: Date? = nil) {
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
    
    func toDTO() -> UserAccountDTO {
        return UserAccountDTO(id: id, userId: userId, teamId: teamId, position: position, role: role, displayName: displayName, createdAt: createdAt, updatedAt: updatedAt, deletedAt: deletedAt)
    }
    
    var roleEnum: UserRole {
        UserRole(rawValue: self.role)!
    }
}
