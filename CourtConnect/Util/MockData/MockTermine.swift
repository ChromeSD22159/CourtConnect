//
//  MockTermine.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 04.02.25.
//
import Foundation

struct MockTermine {
    static let termine: [Termin] = [
        Termin(
            teamId: UUID(),
            title: "U16 Tryout",
            place: "Saderlacherweg 1, 79761 Waldshut",
            infomation: "Tryouts for the upcoming U16 season. All skill levels welcome!",
            typeString: TerminType.training.rawValue,
            durationMinutes: 120,
            startTime: Calendar.current.date(byAdding: .day, value: 7, to: Date())!,
            endTime: Calendar.current.date(byAdding: .day, value: 8, to: Date())!,
            createdByUserAccountId: UUID(),
            createdAt: Date(),
            updatedAt: Date()
        ),
        Termin(
            teamId: UUID(),
            title: "U14 Game vs. Mannheim",
            place: "Vom-Berge-Weg 34, 22159 Hamburg",
            infomation: "Away game against Mannheim. Be there to support the team!",
            typeString: TerminType.game.rawValue,
            durationMinutes: 90,
            startTime: Calendar.current.date(byAdding: .day, value: 14, to: Date())!,
            endTime: Calendar.current.date(byAdding: .day, value: 15, to: Date())!,
            createdByUserAccountId: UUID(),
            createdAt: Date(),
            updatedAt: Date()
        ),
        Termin(
            teamId: UUID(),
            title: "Open Practice",
            place: "Outdoor Court",
            infomation: "Casual practice session, open to all members. Come and have some fun!",
            typeString: TerminType.training.rawValue,
            durationMinutes: 90,
            startTime: Calendar.current.date(byAdding: .day, value: 2, to: Date())!,
            endTime: Calendar.current.date(byAdding: .day, value: 3, to: Date())!,
            createdByUserAccountId: UUID(),
            createdAt: Date(),
            updatedAt: Date()
        ),
        Termin(
            teamId: UUID(),
            title: "Team Meeting",
            place: "Clubhouse",
            infomation: "Important team meeting to discuss upcoming games and strategies.",
            typeString: TerminType.other.rawValue,
            durationMinutes: 60,
            startTime: Calendar.current.date(byAdding: .day, value: 21, to: Date())!,
            endTime: Calendar.current.date(byAdding: .day, value: 22, to: Date())!,
            createdByUserAccountId: UUID(),
            createdAt: Date(),
            updatedAt: Date()
        ),
        Termin(
            teamId: UUID(),
            title: "U18 Game vs. Heidelberg",
            place: "Home Court",
            infomation: "Home game against Heidelberg. Let's pack the stands!",
            typeString: TerminType.game.rawValue,
            durationMinutes: 90,
            startTime: Calendar.current.date(byAdding: .day, value: 31, to: Date())!,
            endTime: Calendar.current.date(byAdding: .day, value: 32, to: Date())!,
            createdByUserAccountId: UUID(),
            createdAt: Date(),
            updatedAt: Date()
        ),

         Termin(
            teamId: UUID(),
            title: "U12 Practice",
            place: "Elementary School Gym",
            infomation: "Practice for the U12 team. Focus on fundamentals.",
            typeString: TerminType.training.rawValue,
            durationMinutes: 60,
            startTime: Calendar.current.date(byAdding: .day, value: 1, to: Date())!,
            endTime: Calendar.current.date(byAdding: .day, value: 2, to: Date())!,
            createdByUserAccountId: UUID(),
            createdAt: Date(),
            updatedAt: Date()
        ),

         Termin(
            teamId: UUID(),
            title: "U16 Scrimmage",
            place: "High School Gym",
            infomation: "Scrimmage game for the U16 team. Good opportunity to practice game situations.",
            typeString: TerminType.game.rawValue,
            durationMinutes: 90,
            startTime: Calendar.current.date(byAdding: .day, value: 5, to: Date())!,
            endTime: Calendar.current.date(byAdding: .day, value: 6, to: Date())!,
            createdByUserAccountId: UUID(),
            createdAt: Date(),
            updatedAt: Date()
        )
    ]
    
    static let attendanceTermine = [
        AttendanceTermin(
            attendance: Attendance(userAccountId: UUID(), terminId: MockTermine.termine[0].id, startTime: Date(), endTime: Date(), attendanceStatus: AttendanceStatus.pending, createdAt: Date(), updatedAt: Date()),
            termin: MockTermine.termine[0]
        ),
        AttendanceTermin(
            attendance: Attendance(userAccountId: UUID(), terminId: MockTermine.termine[1].id, startTime: Date(), endTime: Date(), attendanceStatus: AttendanceStatus.pending, createdAt: Date(), updatedAt: Date()),
            termin: MockTermine.termine[1]
        ),
        AttendanceTermin(
            attendance: Attendance(userAccountId: UUID(), terminId: MockTermine.termine[2].id, startTime: Date(), endTime: Date(), attendanceStatus: AttendanceStatus.pending, createdAt: Date(), updatedAt: Date()),
            termin: MockTermine.termine[2]
        )
    ]
}
