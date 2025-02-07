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
    var userAccountId: UUID
    var terminId: UUID
    var startTime: Date
    var endTime: Date
    var attendanceStatus: String
    var createdAt: Date
    var updatedAt: Date
    var deletedAt: Date?
    var trainerConfirmedAt: Date?
    
    init(id: UUID = UUID(), userAccountId: UUID, terminId: UUID, startTime: Date, endTime: Date, attendanceStatus: AttendanceStatus, createdAt: Date, updatedAt: Date, deletedAt: Date? = nil, trainerConfirmedAt: Date? = nil) {
        self.id = id
        self.userAccountId = userAccountId
        self.terminId = terminId
        self.startTime = startTime
        self.endTime = endTime
        self.attendanceStatus = attendanceStatus.rawValue
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
        self.trainerConfirmedAt = trainerConfirmedAt
    }
    
    func toDTO() -> AttendanceDTO {
        return AttendanceDTO(id: id, userAccountId: userAccountId, terminId: terminId, startTime: startTime, endTime: endTime, attendanceStatus: status, createdAt: createdAt, updatedAt: updatedAt, deletedAt: deletedAt, trainerConfirmedAt: trainerConfirmedAt)
    }
    
    var status: AttendanceStatus {
        AttendanceStatus(rawValue: self.attendanceStatus) ?? .pending
    }
}
