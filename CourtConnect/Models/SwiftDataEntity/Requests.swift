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
    var id: UUID
    var memberId: UUID
    var teamId: UUID
    var createdAt: Date
    var updatedAt: Date
    var deletedAt: Date?
    
    init(id: UUID = UUID(), memberId: UUID, teamId: UUID, createdAt: Date, updatedAt: Date, deletedAt: Date? = nil) {
        self.id = id
        self.memberId = memberId
        self.teamId = teamId
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
    }
    
    func toDTO() -> RequestsDTO {
        return RequestsDTO(id: id, memberId: memberId, teamId: teamId, createdAt: createdAt, updatedAt: updatedAt, deletedAt: deletedAt)
    }
}
