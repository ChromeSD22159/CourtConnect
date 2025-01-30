//
//  GenerateCodeView.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 29.01.25.
//
import SwiftUI

struct GenerateCodeView: View {
    @Environment(\.dismiss) var dismiss
    @State private var viewModel = GenerateCodeViewModel(repository: Repository.shared)
    
    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                
                VStack(spacing: 20) {
                    
                    Image(systemName: "keyboard.badge.ellipsis")
                        .font(.system(size: 100))
                        .foregroundStyle(.darkOrange, LinearGradient(colors: [Theme.darkOrange, Theme.lightOrange], startPoint: .top, endPoint: .bottom))
                    
                    Text("Enter Team's Code")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    HStack(spacing: 12) {
                        ForEach(0..<6, id: \.self) { index in
                          
                          Text(viewModel.code.indices.contains(index) ? String(viewModel.code[index]) : "_")
                              .font(.system(size: 32))
                              .frame(width: 40, height: 50)
                              .background(Color.gray.opacity(0.2))
                              .cornerRadius(8)
                              .animation(.spring, value: viewModel.code)
                        }
                    }
                    
                    HStack(spacing: 10) {
                        Button(action: {
                            viewModel.copy()
                        }, label: {
                            Image(systemName: "doc.on.clipboard")
                        })
                        .tint(Theme.lightOrange)
                        .buttonStyle(.borderedProminent)
                         
                        Button("Generate Code") {
                            viewModel.generateCode()
                        }
                        .tint(Theme.darkOrange)
                        .buttonStyle(.borderedProminent)
                    }
                    
                    if viewModel.message.isEmpty {
                        Text(" ")
                    } else {
                        Text(viewModel.message)
                            .font(.callout)
                            .foregroundStyle(.red)
                    }
                }
                
            }
            .navigationTitle("Generate Code")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading, content: {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(Theme.text)
                })
                
                ToolbarItem(placement: .navigationBarTrailing, content: {
                    Button("Copy") {
                        viewModel.copy()
                        dismiss()
                    }
                    .foregroundStyle(Theme.text)
                })
            }
        }.navigationStackTint()
    }
}

#Preview("Generate") {
    EmptyView()
        .sheet(isPresented: .constant(true), content: {
            ZStack {
                Theme.background.ignoresSafeArea()
                
                GenerateCodeView()
                    .previewEnvirments()
            }
        })
}
