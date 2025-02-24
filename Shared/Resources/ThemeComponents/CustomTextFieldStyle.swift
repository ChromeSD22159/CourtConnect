//
//  CustomTextFieldStyle.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 24.02.25.
//
import SwiftUI
 
struct CustomTextFieldStyle: TextFieldStyle {
    var count: Int
    var max: Int
    
    init(count: Int, max: Int = 10) {
        self.count = count
        self.max = max
    }
    
    // swiftlint:disable:next identifier_name
    func _body(configuration: TextField<Self._Label>) -> some View {
        GeometryReader { geo in
            configuration
                .padding(10)
                .background(Theme.headline.opacity(0.1))
                .overlay(alignment: .bottom) {
                    ZStack(alignment: .leading) {
                        let percentage = 100 / CGFloat(max) * CGFloat(count)
                        let _ = print(percentage)
                        Rectangle()
                            .fill(Material.ultraThinMaterial)
                            .frame(width: .infinity, height: 5)
                        
                        Rectangle()
                            .fill(Theme.textBorderRadient)
                            .frame(width: geo.size.width / 100 * percentage, height: 5)
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
}
