//
//  Theme.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 11.01.25.
//
import SwiftUI

struct Theme {
    static let darkOrange: Color = Color(.darkOrange)
    static let lightOrange: Color = Color(.lightOrange)
    static let white: Color = .white
    
    // BG
    static let background = Color(.background)
    
    static let onBackground: Color = Color(.onBackground)
    static let myGray: Color = Color(.myGray)
    
    static let text: Color = Color(.text)
    static let headline: Color = Color(.headline)
    static let headlineReversed: Color = Color(.headlineReversed)
    
    static let topTrailingbottomLeadingGradient = LinearGradient(colors: [
        Theme.lightOrange,
        Theme.darkOrange
    ], startPoint: .topTrailing, endPoint: .bottomLeading)
    
    static let topBottomLinearGradientReverse = LinearGradient(colors: [
        Theme.darkOrange,
        Theme.lightOrange
    ], startPoint: .top, endPoint: .bottom)
    
    static let backgroundGradient = LinearGradient(stops: [
        Gradient.Stop(color: Theme.lightOrange, location: 0.00),
        Gradient.Stop(color: Theme.darkOrange.opacity(0), location: 0.60)
    ],
    startPoint: UnitPoint(x: 1, y: 0),
    endPoint: UnitPoint(x: 0, y: 1))
    
    static let backgroundGradientReverse = LinearGradient(stops: [
        Gradient.Stop(color: Theme.lightOrange, location: 0.00),
        Gradient.Stop(color: Theme.darkOrange.opacity(0), location: 0.60)
    ],
    startPoint: UnitPoint(x: 0, y: 1),
    endPoint: UnitPoint(x: 1, y: 0))
    
    static let textBorderRadient = LinearGradient(stops: [
        Gradient.Stop(color: Theme.lightOrange, location: 0.00),
        Gradient.Stop(color: Theme.darkOrange, location: 0.60)
    ],
    startPoint: UnitPoint(x: 0, y: 1),
    endPoint: UnitPoint(x: 1, y: 0))
}

extension Text {
    func universidadFont(_ fontWeight: FontWeight? = .regular, _ size: CGFloat? = nil) -> Text {
        return self.font(.universidadFont(fontWeight ?? .regular, size ?? 16))
    }
    
    func jackpotFont(_ fontWeight: FontWeight? = .regular, _ size: CGFloat? = nil) -> Text {
        return self.font(.jackpotFont(fontWeight ?? .regular, size ?? 16))
    }
}
 
extension Font {
    static let jackpotFont: (FontWeight, CGFloat) -> Font = { fontType, size in
        switch fontType {
        case .light:
            Font.custom("JACKPORTCOLLEGENCV", size: size)
        case .regular:
            Font.custom("JACKPORTCOLLEGENCV", size: size)
        case .medium:
            Font.custom("JACKPORTCOLLEGENCV", size: size)
        case .semiBold:
            Font.custom("JACKPORTCOLLEGENCV", size: size)
        case .bold:
            Font.custom("JACKPORTCOLLEGENCV", size: size)
        case .black:
            Font.custom("JACKPORTCOLLEGENCV", size: size)
        }
    }
    
    static let universidadFont: (FontWeight, CGFloat) -> Font = { fontType, size in
        switch fontType {
        case .light:
            Font.custom("UNIVERSIDADPERSONALUSE-Bold", size: size)
        case .regular:
            Font.custom("UNIVERSIDADPERSONALUSE-Bold", size: size)
        case .medium:
            Font.custom("UNIVERSIDADPERSONALUSE-Bold", size: size)
        case .semiBold:
            Font.custom("UNIVERSIDADPERSONALUSE-Bold", size: size)
        case .bold:
            Font.custom("UNIVERSIDADPERSONALUSE-Bold", size: size)
        case .black:
            Font.custom("UNIVERSIDADPERSONALUSE-Bold", size: size)
        }
    }
}

enum FontWeight {
    case light
    case regular
    case medium
    case semiBold
    case bold
    case black
}

extension Color {
    init(hex: String) {
           let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
           var int: UInt64 = 0
           Scanner(string: hex).scanHexInt64(&int)
           let aValue, rValue, gValue, bValue: UInt64
           switch hex.count {
           case 3: // RGB (12-bit)
               (aValue, rValue, gValue, bValue) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
           case 6: // RGB (24-bit)
               (aValue, rValue, gValue, bValue) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
           case 8: // ARGB (32-bit)
               (aValue, rValue, gValue, bValue) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
           default:
               (aValue, rValue, gValue, bValue) = (1, 1, 1, 0)
           }

           self.init(
               .sRGB,
               red: Double(rValue) / 255,
               green: Double(gValue) / 255,
               blue:  Double(bValue) / 255,
               opacity: Double(aValue) / 255
           )
       }
}

#Preview {
    @Previewable  @Environment(\.colorScheme) var colorScheme
    ZStack {
        Theme.backgroundGradientReverse
        
        Text("110 : 98")
            .foregroundStyle(colorScheme == .light ? .black.opacity(0.1) : .white.opacity(0.1))
            .font(.jackpotFont(.black, 150))
        
    }.ignoresSafeArea()
}
