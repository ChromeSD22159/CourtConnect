//
//  File.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 07.02.25.
// 
import Foundation
 
extension Date {
    func toDateStringDDMM() -> String {
        self.formatted(.dateTime.day(.twoDigits).month(.twoDigits))
    }
    
    func toDateString() -> String {
        self.formatted(.dateTime.day(.twoDigits).month(.twoDigits).year(.twoDigits))
    }
    
    func toTimeStringWithSuffix() -> String {
        self.formatted(.dateTime.hour().minute()) + "Uhr"
    }
    
    func toTimeString() -> String {
        self.formatted(.dateTime.hour().minute())
    } 
}
