//
//  PlayerRow.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 13.02.25.
//
import SwiftUI

struct PlayerRow: View {
    @State var isExpant = false
    let member: MemberProfile
    let isTrainer: Bool
    
    init(member: MemberProfile, isTrainer: Bool) {
        self.member = member
        self.isTrainer = isTrainer
    }
    
    var body: some View {
        VStack(spacing: 20) {
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    if let number = member.shirtNumber {
                        Text("\(member.fullName) (\(number))")
                            .fontWeight(.bold)
                    } else {
                        Text("\(member.fullName)")
                            .fontWeight(.bold)
                    }
                     
                    if let position = member.position {
                        Text(position)
                            .font(.footnote)
                    }
                }
                Spacer()
                if !isTrainer {
                    VStack {
                        Image(systemName: "chevron.down")
                            .rotationEffect(.degrees(isExpant ? 0 : -90))
                            .animation(.easeInOut, value: isExpant)
                            .background {
                                Rectangle()
                                    .fill(.black.opacity(0.0001))
                                    .frame(width: 150, height: 40)
                                    .onTapGesture {
                                        withAnimation(.easeInOut) {
                                            isExpant.toggle()
                                        }
                                    }
                            }
                    }
                }
            }
            .padding()
            .background(Material.ultraThinMaterial.opacity(0.8))
            .borderRadius(15)
            
            if isExpant {
                HStack(spacing: 25) {
                    valueIcon(icon: .customFigureBasketballFoul, value: member.avgFouls)
                    
                    valueIcon(icon: .customBasketball2Fill, value: member.avgTwo)
                    
                    valueIcon(icon: .customBasketball3Fill, value:  member.avgtree)
                    
                    valueIcon(icon: "trophy.fill", value: member.avgPoints)
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
        }
        .background(Material.ultraThinMaterial.opacity(0.8))
        .borderRadius(15)
    }
    
    @ViewBuilder func valueIcon(icon: String, value: Int) -> some View {
        HStack(alignment: .center) {
            Image(systemName: icon)
                .font(.title)
            
            Text(String("x\(value)"))
                .font(.subheadline)
        }
    }
    
    @ViewBuilder func valueIcon(icon: ImageResource, value: Int) -> some View {
        HStack(alignment: .center) {
            Image(icon)
                .font(.title)
            
            Text(String("x\(value)"))
                .font(.subheadline)
        } 
    }
}
