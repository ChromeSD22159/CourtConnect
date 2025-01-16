//
//  DateUtil.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 12.01.25.
//
import Foundation

struct DateUtil {
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-DD'T'HH:mm:ss.SSS'Z'"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        return formatter
      }()
    
    static func convertDateToString(date: Date) -> String {
        return dateFormatter.string(from: date)
    }
    
    static func convertDateStringToDate(string: String) -> Date? { 
        return dateFormatter.date(from: string) 
    }
}
