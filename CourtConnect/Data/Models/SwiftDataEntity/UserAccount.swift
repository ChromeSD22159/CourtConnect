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
    var userId: String
    var teamId: String
    var position: String
    var role: String
    var createdAt: Date
    var updatedAt: Date
    var isDeleted: Bool
    var isBlocked: Bool
    
    init(id: UUID = UUID(), userId: String, teamId: String, position: String, role: String, createdAt: Date, updatedAt: Date, isDeleted: Bool = false, isBlocked: Bool = false) {
        self.id = id
        self.userId = userId
        self.teamId = teamId
        self.position = position
        self.role = role
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.isDeleted = isDeleted
        self.isBlocked = isBlocked
    }
    
    func toUserAccountDTO() -> UserAccountDTO {
        return UserAccountDTO(id: id, userId: userId, teamId: teamId, position: position, role: role, createdAt: createdAt, updatedAt: updatedAt, isDeleted: isDeleted, isBlocked: isBlocked)
    }
}
