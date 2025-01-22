//
//  InAppMessagehandler.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 21.01.25.
//
import Foundation
 
@Observable class InAppMessagehandler: Observable {
    static let shared = InAppMessagehandler()
    
    var message: InAppMessage?
    
    func handleMessage(message: InAppMessage) {
        self.message = message
        
        Timer.scheduledTimer(withTimeInterval: 2, repeats: false, block: { _ in
            self.message = nil
        })
    }
}
