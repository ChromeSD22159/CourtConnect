//
//  SizeCalculator.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 11.02.25.
//
import SwiftUI 

struct SizeCalculator: ViewModifier {
    
    @Binding var size: CGSize
    
    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { proxy in
                    Color.clear
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) { // Small delay
                                size = proxy.size
                            }
                        }
                        .onChange(of: proxy.size) {
                            size =  proxy.size
                        }
                }
            )
    }
}

extension View {
    func saveSize(in size: Binding<CGSize>) -> some View {
        modifier(SizeCalculator(size: size))
    }
}
