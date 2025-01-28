//
//  ConfettiViewModel.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 28.01.25.
// 
import Foundation

@Observable class ConfettiViewModel: ObservableObject {
    static let shared = ConfettiViewModel()
    
    var isAnimating = false
    
    func trigger() {
        Task {
            self.isAnimating.toggle()
            
            try await Task.sleep(for: .seconds(1))
            
            self.isAnimating.toggle()
        }
    }
}
