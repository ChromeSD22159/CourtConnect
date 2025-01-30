//
//  Attendance.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 27.01.25.
//
import SwiftData
import Foundation

@Model
class Attendance: ModelProtocol {
    @Attribute(.unique) var id: UUID
    var trainerId: UUID
    var terminId: UUID
    var startTime: Date
    var endTime: Date
    var createdAt: Date
    var updatedAt: Date
    var deletedAt: Date?
    
    init(id: UUID = UUID(), trainerId: UUID, terminId: UUID, startTime: Date, endTime: Date, createdAt: Date, updatedAt: Date, deletedAt: Date? = nil) {
        self.id = id
        self.trainerId = trainerId
        self.terminId = terminId
        self.startTime = startTime
        self.endTime = endTime
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
    }
    
    func toDTO() -> AttendanceDTO {
        return AttendanceDTO(id: id, trainerId: trainerId, terminId: terminId, startTime: startTime, endTime: endTime, createdAt: createdAt, updatedAt: updatedAt, deletedAt: deletedAt)
    }
}
