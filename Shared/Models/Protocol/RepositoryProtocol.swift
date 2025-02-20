//
//  RepositoryProtocol.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 20.02.25.
// 
import SwiftData


@MainActor protocol RepositoryProtocol {
    var container: ModelContainer { get set }
} 
