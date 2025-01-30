//
//  Shake.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 31.01.25.
//
import SwiftUI

struct Shake: AnimatableModifier {
    var shakes: CGFloat = 0
    
    var animatableData: CGFloat {
        get {
            shakes
        } set {
            shakes = newValue
        }
    }
    
    func body(content: Content) -> some View {
        content
            .offset(x: sin(shakes * .pi * 2) * 5)
    }
}

extension View {
    /// Wendet eine Schüttel-Animation auf die View an.
    ///
    /// Verwende diesen Modifikator, um einer View einen horizontalen Schüttel-Effekt hinzuzufügen.
    /// Die Intensität und Dauer des Schüttelns werden durch den Parameter `shakes` gesteuert.
    /// Wenn sich `shakes` ändert, wird die View die Schüttel-Animation ausführen.
    ///
    /// # Beispiel:
    /// ```swift
    /// @State private var numberOfShakes: CGFloat = 0.0
    ///
    /// Button("Schütteln") {
    ///     withAnimation {
    ///         numberOfShakes += 10 // Erhöhe die Anzahl der Schüttelbewegungen
    ///     }
    /// }
    /// .shake(with: numberOfShakes)
    /// ```
    ///
    /// - Parameter shakes: Die Anzahl der Schüttelbewegungen. Dieser Wert wird typischerweise animiert, um den Schüttel-Effekt zu erzeugen.
    /// - Returns: Eine View, auf die der Schüttel-Effekt angewendet wurde.
    func shake(with shakes: CGFloat) -> some View {
        modifier(Shake(shakes: shakes))
    }
}

#Preview {
    @Previewable @State var numberOfShakes = 0.0
    
    Button("Tap") {
        withAnimation {
            numberOfShakes += 2
        }
    }
    .shake(with: numberOfShakes)
}
