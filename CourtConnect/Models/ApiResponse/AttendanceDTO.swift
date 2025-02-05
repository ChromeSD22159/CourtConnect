//
//  AttendanceDTO.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 27.01.25.
//
import Foundation

struct AttendanceDTO: DTOProtocol {
    var id: UUID
    var trainerId: UUID
    var terminId: UUID
    var startTime: Date
    var endTime: Date
    var attendanceStatus: String
    var createdAt: Date
    var updatedAt: Date
    var deletedAt: Date?
    
    init(id: UUID = UUID(), trainerId: UUID, terminId: UUID, startTime: Date, endTime: Date, attendanceStatus: AttendanceStatus, createdAt: Date, updatedAt: Date, deletedAt: Date? = nil) {
        self.id = id
        self.trainerId = trainerId
        self.terminId = terminId
        self.startTime = startTime
        self.endTime = endTime
        self.attendanceStatus = attendanceStatus.rawValue
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
    }
    
    func toModel() -> Attendance {
        Attendance(id: id, trainerId: trainerId, terminId: terminId, startTime: startTime, endTime: endTime, attendanceStatus: status, createdAt: createdAt, updatedAt: updatedAt, deletedAt: deletedAt)
    }
    
    var status: AttendanceStatus {
        AttendanceStatus(rawValue: self.attendanceStatus) ?? .pending
    }
} 
