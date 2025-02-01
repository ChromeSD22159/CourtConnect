//
//  TerminDuration.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 01.02.25.
//
 
enum TerminDuration: String, CaseIterable, Identifiable {
    case fifteen = "15"
    case thirty = "30"
    case fortyFive = "45"
    case sixty = "1h"
    case ninety = "90"
    case oneTwenty = "2h"
    case oneEighty = "2.5h"
    case twoForty = "3h"
    case threeHundred = "3.5h"

    var durationMinutes: Int {
        switch self {
        case .fifteen: return 15
        case .thirty: return 30
        case .fortyFive: return 45
        case .sixty: return 60
        case .ninety: return 90
        case .oneTwenty: return 120
        case .oneEighty: return 180
        case .twoForty: return 240
        case .threeHundred: return 300
        }
    }
    
    var id: String { rawValue }
}
