//
//  AttendanceTermin.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 09.02.25.
//
import Foundation

struct AttendanceTermin: Identifiable {
    let id: UUID
    let attendance: Attendance
    let termin: Termin
    
    init(id: UUID = UUID(), attendance: Attendance, termin: Termin) {
        self.id = id
        self.attendance = attendance
        self.termin = termin
    }
}
