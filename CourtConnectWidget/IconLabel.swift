//
//  IconLabel.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 09.02.25.
//
import SwiftUI

struct IconLabel: View {
    let imageResource: ImageResource?
    let systemName: String?
    let value: Int
    
    init(imageResource: ImageResource?, value: Int) {
        self.imageResource = imageResource
        self.systemName = nil
        self.value = value
    }
    
    init(systemName: String?, value: Int) {
        self.imageResource = nil
        self.systemName = systemName
        self.value = value
    }
    
    var body: some View {
        HStack {
            if let imageResource = imageResource {
                Image(imageResource)
                    .font(.system(size: 18))
            }
            if let systemName = systemName {
                Image(systemName: systemName)
                    .font(.system(size: 18))
            }
            
            Text("x\(value.formatted())")
                .font(.system(size: 12))
        }
    }
}
