//
//  Statistic.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 28.01.25.
//
import SwiftData
import Foundation

@Model
class Statistic: ModelProtocol {
    @Attribute(.unique) var id: UUID
    var userAccountId: UUID
    var fouls: Int
    var twoPointAttempts: Int
    var threePointAttempts: Int
    var createdAt: Date
    var updatedAt: Date
    var deletedAt: Date?
    
    init(id: UUID, userAccountId: UUID, fouls: Int, twoPointAttempts: Int, threePointAttempts: Int, createdAt: Date, updatedAt: Date, deletedAt: Date? = nil) {
        self.id = id
        self.userAccountId = userAccountId
        self.fouls = fouls
        self.twoPointAttempts = twoPointAttempts
        self.threePointAttempts = threePointAttempts
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
    }
    
    var points: Int {
        (twoPointAttempts * 2) + (threePointAttempts * 3)
    }
    
    func toDTO() -> StatisticDTO {
        return StatisticDTO(id: id, userAccountId: userAccountId, fouls: fouls, twoPointAttempts: twoPointAttempts, threePointAttempts: threePointAttempts, createdAt: createdAt, updatedAt: updatedAt, deletedAt: deletedAt)
    }
}
