//
//  Account.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 23.01.25.
//
import SwiftData
import Foundation

@Model
class UserAccount: Identifiable {
    @Attribute(.unique) var id: UUID
    var userId: UUID
    var teamId: String
    var position: String
    var role: String
    var createdAt: Date
    var updatedAt: Date
    var deletedAt: Date?
    
    init(id: UUID = UUID(), userId: UUID, teamId: String, position: String, role: String, createdAt: Date, updatedAt: Date, deletedAt: Date? = nil) {
        self.id = id
        self.userId = userId
        self.teamId = teamId
        self.position = position
        self.role = role
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
    }
    
    func toUserAccountDTO() -> UserAccountDTO {
        return UserAccountDTO(id: id, userId: userId, teamId: teamId, position: position, role: role, createdAt: createdAt, updatedAt: updatedAt, deletedAt: deletedAt)
    }
}
