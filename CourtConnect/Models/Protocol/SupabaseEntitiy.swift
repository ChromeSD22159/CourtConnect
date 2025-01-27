//
//  SupabaseEntitiy.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 27.01.25.
//

import Foundation
 
protocol SupabaseEntitiy {
    var id: UUID { get set }
    var createdAt: Date { get set }
    var updatedAt: Date { get set }
    var deletedAt: Date? { get set }
}  
