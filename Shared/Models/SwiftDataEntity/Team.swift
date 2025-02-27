//
//  Team.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 24.01.25.
//
import SwiftData
import Foundation

@Model class Team: ModelProtocol { 
    @Attribute(.unique) var id: UUID
    var teamImageURL: String?
    var teamName: String
    var headcoach: String
    var joinCode: String
    var email: String
    var coachHourlyRate: Double = 0.00
    var addStatisticConfirmedOnly: Bool = false
    var createdByUserAccountId: UUID
    var createdAt: Date
    var updatedAt: Date
    var deletedAt: Date?
    
    init(
        id: UUID = UUID(),
        teamImageURL: String?,
        teamName: String,
        headcoach: String,
        joinCode: String,
        email: String,
        coachHourlyRate: Double?,
        addStatisticConfirmedOnly: Bool?,
        createdByUserAccountId: UUID,
        createdAt: Date,
        updatedAt: Date,
        deletedAt: Date? = nil
    ) {
        self.id = id
        self.teamImageURL = teamImageURL
        self.teamName = teamName
        self.headcoach = headcoach
        self.joinCode = joinCode
        self.email = email
        self.coachHourlyRate = coachHourlyRate ?? 0.00
        self.addStatisticConfirmedOnly = addStatisticConfirmedOnly ?? false
        self.createdByUserAccountId = createdByUserAccountId
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
    }
    
    func toDTO() -> TeamDTO {
        return TeamDTO(id: id, teamImageURL: teamImageURL, teamName: teamName, headcoach: headcoach, joinCode: joinCode, email: email, coachHourlyRate: coachHourlyRate, addStatisticConfirmedOnly: addStatisticConfirmedOnly, createdByUserAccountId: createdByUserAccountId, createdAt: createdAt, updatedAt: updatedAt, deletedAt: deletedAt)
    }
} 
