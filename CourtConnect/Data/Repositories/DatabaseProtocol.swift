//
//  DatabaseProtocol.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 11.01.25.
// 
import SwiftData
 
protocol DatabaseProtocol {
    var type: RepositoryType { get }
    var container: ModelContainer { get } 
}
