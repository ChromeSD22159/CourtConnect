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
    var date: Date
    var createdAt: Date
    var updatedAt: Date
    var deletedAt: Date?
    
    init(id: UUID = UUID(), userAccountId: UUID, teamId: UUID, date: Date, createdAt: Date, updatedAt: Date, deletedAt: Date? = nil) {
        self.id = id
        self.userAccountId = userAccountId
        self.teamId = teamId
        self.date = date
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
    }
    
    func toDTO() -> AbsenceDTO {
        return AbsenceDTO(id: id, userAccountId: userAccountId, teamId: teamId, date: date, createdAt: createdAt, updatedAt: updatedAt, deletedAt: deletedAt)
    }
}
