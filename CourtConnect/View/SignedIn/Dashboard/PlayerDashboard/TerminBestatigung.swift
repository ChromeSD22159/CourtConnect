//
//  confirmationAppointment.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 06.02.25.
//
import SwiftUI 

struct ConfirmationTermin: View {
    let attendanceTermines: [AttendanceTermin]
    let onConfirm: (Attendance) -> Void
    
    init(attendanceTermines: [AttendanceTermin], onConfirm: @escaping (Attendance) -> Void = {_ in}) {
        self.attendanceTermines = attendanceTermines
        self.onConfirm = onConfirm
    }
    
    @State var shortAttendances = false
    
    var body: some View {
        VStack(alignment: .leading) {
            UpperCasedheadline(text: "Attendances")
            
            LazyVStack {
                if attendanceTermines.isEmpty {
                    HStack {
                        Text("You have no open appointment confirmations")
                    }
                    .padding()
                    .background(Material.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                }
                if shortAttendances {
                    ForEach(Array(attendanceTermines.prefix(2))) { attendanceTermin in
                        CheckRow(termin: attendanceTermin.termin) { answer in
                            if answer {
                                attendanceTermin.attendance.attendanceStatus = AttendanceStatus.confirmed.rawValue
                                onConfirm(attendanceTermin.attendance)
                            } else {
                                attendanceTermin.attendance.attendanceStatus = AttendanceStatus.declined.rawValue
                                onConfirm(attendanceTermin.attendance)
                            }
                            
                        }
                    }
                } else {
                    ForEach(attendanceTermines) { attendanceTermin in
                        CheckRow(termin: attendanceTermin.termin) { answer in
                            if answer {
                                attendanceTermin.attendance.attendanceStatus = AttendanceStatus.confirmed.rawValue
                                onConfirm(attendanceTermin.attendance)
                            } else {
                                attendanceTermin.attendance.attendanceStatus = AttendanceStatus.declined.rawValue
                                onConfirm(attendanceTermin.attendance)
                            }
                            
                        }
                    }
                }
            }
            if attendanceTermines.count > 2 {
                HStack {
                    Spacer()
                    ShowModeTextButton(showAll: $shortAttendances) 
                }
            }
        }
    }
}

fileprivate struct CheckRow:View {
    let termin: Termin
    let onClick: (Bool) -> Void
    var body: some View {
        HStack {
            Text(termin.title)
            
            Spacer()
            
            IconRoundedRectangle(systemName: "checkmark", foreground: .white, background: Theme.lightOrange) {
                onClick(true)
            }
            
            IconRoundedRectangle(systemName: "xmark", foreground: .white, background: Theme.myGray) {
                onClick(false)
            }
        }
        .padding()
        .background(Material.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 15))
    }
}

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

#Preview {
    let list = MockTermine.attendanceTermine
    
    ScrollView {
        ConfirmationTermin(attendanceTermines: list)
    }
    .contentMargins(.horizontal, 16)
}
