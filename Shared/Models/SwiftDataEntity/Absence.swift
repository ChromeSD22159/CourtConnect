//
//  Absence.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 04.02.25.
//
import SwiftData
import Foundation

@Model class Absence: ModelProtocol {
    @Attribute(.unique) var id: UUID
    var userAccountId: UUID
    var teamId: UUID
    var startDate: Date
    var endDate: Date
    var createdAt: Date
    var updatedAt: Date
    var deletedAt: Date?
    
    init(id: UUID = UUID(), userAccountId: UUID, teamId: UUID, startDate: Date, endDate: Date, createdAt: Date, updatedAt: Date, deletedAt: Date? = nil) {
        self.id = id
        self.userAccountId = userAccountId
        self.teamId = teamId
        self.startDate = startDate
        self.endDate = endDate
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
    }
    
    func toDTO() -> AbsenceDTO {
        return AbsenceDTO(id: id, userAccountId: userAccountId, teamId: teamId, startDate: startDate, endDate: endDate, createdAt: createdAt, updatedAt: updatedAt, deletedAt: deletedAt)
    }
}
