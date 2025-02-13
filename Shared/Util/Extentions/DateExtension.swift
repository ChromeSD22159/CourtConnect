//
//  File.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 17.01.25.
//
import Foundation
import SwiftUICore

extension Date {
    func formattedDate() -> LocalizedStringKey {
        let formattedDate = self.formatted(
            .dateTime
                .day(.twoDigits)
                .month(.twoDigits)
                .year(.twoDigits)
        )
        
        return LocalizedStringKey(formattedDate)
    }
    
    func formattedDateDDMM() -> LocalizedStringKey {
        let formattedDate = self.formatted(
            .dateTime
                .day(.twoDigits)
                .month(.twoDigits)
        )
        return LocalizedStringKey(formattedDate)
    }
    
    func formattedTime() -> LocalizedStringKey {
        let formattedDate = self.formatted(
            .dateTime
                .hour(.twoDigits(amPM: .narrow))
                .minute(.twoDigits)
        )
        return LocalizedStringKey(formattedDate)
    }
}
