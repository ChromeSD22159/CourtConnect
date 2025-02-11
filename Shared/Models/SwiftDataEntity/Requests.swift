//
//  Requests.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 27.01.25.
//
import Foundation
import SwiftData

@Model
class Requests: ModelProtocol {
    @Attribute(.unique) var id: UUID
    var accountId: UUID
    var teamId: UUID
    var createdAt: Date
    var updatedAt: Date
    var deletedAt: Date?
    
    init(id: UUID = UUID(), accountId: UUID, teamId: UUID, createdAt: Date, updatedAt: Date, deletedAt: Date? = nil) {
        self.id = id
        self.accountId = accountId
        self.teamId = teamId
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
    }
    
    func toDTO() -> RequestsDTO {
        return RequestsDTO(id: id, accountId: accountId, teamId: teamId, createdAt: createdAt, updatedAt: updatedAt, deletedAt: deletedAt)
    }
}
