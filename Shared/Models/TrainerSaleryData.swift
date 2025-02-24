//
//  TrainerSaleryData.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 21.02.25.
// 
import Foundation
 
struct TrainerSaleryData: Identifiable {
    let id: UUID = UUID()
    let fullName: String
    let hours: Double
    var hourlyRate: Double
    
    var totalSalery: Double {
        self.hours * self.hourlyRate
    }
}
