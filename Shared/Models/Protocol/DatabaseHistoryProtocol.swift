//
//  DatabaseHistoryProtocol.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 27.01.25.
//

import Foundation

protocol DatabaseHistoryProtocol {
    var id: UUID { get set }
    var tableString: String { get set }
    var userId: UUID { get set }
    var timestamp: Date { get set }
}
