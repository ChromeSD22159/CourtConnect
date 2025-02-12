//
//  FontHelper.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 12.02.25.
//

import UIKit

struct FontHelper {
    static func printAllAvaibleFonts() {
        for family in UIFont.familyNames {
            print("Family: \(family)")
            for name in UIFont.fontNames(forFamilyName: family) {
                print("   - \(name)")
            }
        }
    }
}
