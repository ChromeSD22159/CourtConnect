//
//  BasketballPosition.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 23.01.25.
//  
import SwiftUICore

enum BasketballPosition: String, CaseIterable, Identifiable {
    case pointGuard = "Point Guard"
    case shootingGuard = "Shooting Guard"
    case smallForward = "Small Forward"
    case powerForward = "Power Forward"
    case center = "Center"
    
    var id: Self { self }
}
