//
//  Termine.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 27.01.25.
//
import Foundation
import SwiftData

@Model
class Termine: ModelProtocol {
    @Attribute(.unique) var id: UUID
    var teamId: UUID
    var typeString: String
    var locationId: UUID
    var date: Date
    var createdAt: Date
    var updatedAt: Date
    var deletedAt: Date?
   
    init(id: UUID = UUID(), teamId: UUID, typeString: String, locationId: UUID, date: Date, createdAt: Date, updatedAt: Date, deletedAt: Date? = nil) {
        self.id = id
        self.teamId = teamId
        self.typeString = typeString
        self.locationId = locationId
        self.date = date
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
    }
    
    func toDTO() -> TermineDTO {
        return TermineDTO(id: id, teamId: teamId, typeString: typeString, locationId: locationId, date: date, createdAt: createdAt, updatedAt: updatedAt, deletedAt: deletedAt)
    }
}
