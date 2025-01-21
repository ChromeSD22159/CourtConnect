//
//  Errorhandler.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 21.01.25.
//
import Foundation

@Observable class Errorhandler: Observable {
    static let shared = Errorhandler()
    var error: Error?
    
    func handleError(error: Error) {
        self.error = error
        
        Timer.scheduledTimer(withTimeInterval: 2, repeats: false, block: { _ in
            self.error = nil
        })
    }
}
