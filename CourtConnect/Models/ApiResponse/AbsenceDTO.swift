//
//  AbsenceDTO.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 04.02.25.
//
import Foundation

struct AbsenceDTO: DTOProtocol {
    var id: UUID
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
    
    func toModel() -> Absence {
        Absence(id: id, userAccountId: userAccountId, teamId: teamId, date: date, createdAt: createdAt, updatedAt: updatedAt, deletedAt: deletedAt)
    }
} 
