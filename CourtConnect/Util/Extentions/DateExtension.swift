//
//  File.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 17.01.25.
//
import Foundation

extension Date {
    func formattedDate() -> String {
        self.formatted(
            .dateTime
                .day(.twoDigits)
                .month(.twoDigits)
                .year(.twoDigits)
        )
    }
    
    func formattedTime() -> String {
        self.formatted(
            .dateTime
                .hour(.twoDigits(amPM: .narrow))
                .minute(.twoDigits)
        )
    }
}
