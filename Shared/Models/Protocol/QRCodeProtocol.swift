//
//  QRCodeProtocol.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 18.02.25.
//
import UIKit

@MainActor protocol QRCodeProtocol: AuthProtocol {
    var qrCode: UIImage? { get set }
    var joinCode: String { get set }
}

extension QRCodeProtocol {
     func generateQrCode() {
        if let currentTeam = currentTeam {
            joinCode = currentTeam.joinCode
            qrCode = QRCodeHelper().generateQRCode(from: currentTeam.joinCode)
        }
    }
}
