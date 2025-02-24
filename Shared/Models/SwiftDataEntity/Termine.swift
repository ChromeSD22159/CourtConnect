//
//  Termine.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 27.01.25.
//
import Foundation
import SwiftData

@Model
class Termin: ModelProtocol {
    @Attribute(.unique) var id: UUID
    var teamId: UUID
    var title: String
    var place: String
    var infomation: String
    var typeString: String
    var durationMinutes: Int
    var startTime: Date
    var endTime: Date
    var createdByUserAccountId: UUID
    var createdAt: Date
    var updatedAt: Date
    var deletedAt: Date?

    init(id: UUID = UUID(), teamId: UUID, title: String, place: String, infomation: String, typeString: String, durationMinutes: Int, startTime: Date, endTime: Date, createdByUserAccountId: UUID, createdAt: Date, updatedAt: Date, deletedAt: Date? = nil) {
        self.id = id
        self.teamId = teamId
        self.title = title
        self.place = place
        self.infomation = infomation
        self.typeString = typeString
        self.durationMinutes = durationMinutes
        self.startTime = startTime
        self.endTime = endTime
        self.createdByUserAccountId = createdByUserAccountId
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
    }
    
    func toDTO() -> TerminDTO { 
        return TerminDTO(id: id, teamId: teamId, title: title, place: place, infomation: infomation, typeString: typeString, durationMinutes: durationMinutes, startTime: startTime, endTime: endTime, createdByUserAccountId: createdByUserAccountId, createdAt: createdAt, updatedAt: updatedAt, deletedAt: deletedAt)
    }
}
