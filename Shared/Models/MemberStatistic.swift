//
//  MemberStatistic.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 04.02.25.
//
import Foundation

class MemberStatistic {
    var avgFouls: Int
    var avgTwoPointAttempts: Int
    var avgThreePointAttempts: Int
    var avgPoints: Int
    
    init(avgFouls: Int, avgTwoPointAttempts: Int, avgThreePointAttempts: Int, avgPoints: Int) {
        self.avgFouls = avgFouls
        self.avgTwoPointAttempts = avgTwoPointAttempts
        self.avgThreePointAttempts = avgThreePointAttempts
        self.avgPoints = avgPoints
    }
}
