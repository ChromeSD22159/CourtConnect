//
//  TeamDTO.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 27.01.25.
//
import Foundation
 
struct TeamDTO: DTOProtocol {
    var id: UUID
    var teamName: String
    var createdBy: String
    var headcoach: String
    var createdAt: Date
    var updatedAt: Date
    var deletedAt: Date?
    
    init(id: UUID = UUID(), teamName: String, createdBy: String, headcoach: String, createdAt: Date, updatedAt: Date, deletedAt: Date? = nil) {
        self.id = id
        self.teamName = teamName
        self.createdBy = createdBy
        self.headcoach = headcoach
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
    }
    
    func toModel() -> Team {
        return Team(id: id, teamName: teamName, createdBy: createdBy, headcoach: headcoach, createdAt: createdAt, updatedAt: updatedAt, deletedAt: deletedAt)
    }
}

/*
struct TeamAdminDTO: Codable {
    var id: UUID
    var teamId: UUID
    var userId: UUID
    var role: String
}
struct TeamMemberDTO: Codable {
    var id: UUID
    var userId: UUID
    var teamId: UUID
}

struct TermineDTO: Codable, SupabaseEntitiy {
    var id: UUID
    var locationId: UUID
    var isDeleted: Bool
    var createdAt: Date
    var updatedAt: Date
    var deletedAt: Date?
    
    init(id: UUID = UUID(), locationId: UUID, isDeleted: Bool, createdAt: Date, updatedAt: Date, deletedAt: Date? = nil) {
        self.id = id
        self.locationId = locationId
        self.isDeleted = isDeleted
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
    }
}
struct LocationDTO: Codable, SupabaseEntitiy {
    var id: UUID
    var name: String
    var street: String
    var number: String
    var zip: String
    var city: String
    var createdAt: Date
    var updatedAt: Date
    var deletedAt: Date?
}
struct InterestDTO: Codable, SupabaseEntitiy {
    var id: UUID
    var memberId: UUID
    var terminId: UUID
    var willParticipate: Bool
    var createdAt: Date
    var updatedAt: Date
    var deletedAt: Date?
}

// only Live
struct RequestsDTO: Codable, SupabaseEntitiy {
    var id: UUID
    var memberId: UUID
    var teamId: UUID
    var createdAt: Date
    var updatedAt: Date
    var deletedAt: Date?
}

// abruf bei trainer
struct AttendanceDTO: Codable, SupabaseEntitiy {
    var id: UUID
    var trainerId: UUID
    var terminId: UUID
    var startTime: Date
    var endTime: Date
    var createdAt: Date
    var updatedAt: Date
    var deletedAt: Date?
}
*/
