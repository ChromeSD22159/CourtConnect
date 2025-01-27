//
//  StatisticDTO.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 28.01.25.
//
import Foundation

struct StatisticDTO: DTOProtocol {
    var id: UUID
    var userId: UUID
    var fouls: Int
    var twoPointAttempts: Int
    var threePointAttempts: Int
    var points: Int
    var createdAt: Date
    var updatedAt: Date
    var deletedAt: Date?
    
    init(id: UUID, userId: UUID, fouls: Int, twoPointAttempts: Int, threePointAttempts: Int, points: Int, createdAt: Date, updatedAt: Date, deletedAt: Date? = nil) {
        self.id = id
        self.userId = userId
        self.fouls = fouls
        self.twoPointAttempts = twoPointAttempts
        self.threePointAttempts = threePointAttempts
        self.points = points
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
    }
    
    func toModel() -> Statistic {
        return Statistic(id: id, userId: userId, fouls: fouls, twoPointAttempts: twoPointAttempts, threePointAttempts: threePointAttempts, points: points, createdAt: createdAt, updatedAt: updatedAt, deletedAt: deletedAt)
    }
}
