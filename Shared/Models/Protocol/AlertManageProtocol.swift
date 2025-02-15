//
//  AlertManageProtocol.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 15.02.25.
// 
import UIKit
import SwiftUI

protocol AlertManageProtocol {
    var viewController: UIViewController? { get set }
}

extension AlertManageProtocol {
    func showInfomationAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        DispatchQueue.main.async {
            self.viewController?.present(alert, animated: true)
        }
    }
} 
