//
//  WidgetStatistic.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 17.02.25.
// 
import Foundation
 
struct WidgetStatistic: Codable {
    var date: Date
    var fullName: String
    var two: Int
    var three: Int
    var foul: Int
    var points: Int {
        (two * 2) + (three * 3)
    }
}
