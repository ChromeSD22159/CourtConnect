//
//  OnAppiearAnimation.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 02.02.25.
//
import Foundation
 
protocol OnAppiearAnimation: ObservableObject {
    var animateOnAppear: Bool { get set }
}

extension OnAppiearAnimation {
    func startAnimation() {
        DispatchQueue.main.async {
            self.animateOnAppear = true
        }
    }
    
    func resetAnimationState() {
        self.animateOnAppear = false
    }
}
