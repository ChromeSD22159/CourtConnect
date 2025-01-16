//
//  DateUtil.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 12.01.25.
//
import Foundation

struct DateUtil {

    /// A private ISO8601DateFormatter that is initialized once
    /// and can be reused to save storage space
    static private let isoDateFormatter: ISO8601DateFormatter = {
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return dateFormatter
    }()

    /// Converts a date to a string in ISO8601 format
    /// with InternetDateTime and fractions of a second
    static func convertDateToString(date: Date) -> String {
        return isoDateFormatter.string(from: date)
    }

    /// Converts a string in ISO8601 format using InternetDateTime
    /// and fractions of a second into a date
    static func convertDateStringToDate(string: String) -> Date? {
        return isoDateFormatter.date(from: string)
    }
    
    
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter
    }()

    static func stringToDateDDMMYYYY(string: String) -> Date? {
        return dateFormatter.date(from: string)
    }

    static func dateDDMMYYYYToString(date: Date) -> String {
        return dateFormatter.string(from: date)
    }
}
