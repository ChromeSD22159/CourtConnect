//
//  EnterCodeView.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 28.01.25.
//
import SwiftUI

@Observable class CodeEntryViewModel {
    var code: [Character] = []
    
    var message: String = " "

    var codeString: [String] {
        return code.map { String($0) }
    }
    
    func addDigit(_ digit: String) {
        if code.count < 6, let char = digit.first {
            code.append(char)
        }
    }

    func deleteLastDigit() {
        if !code.isEmpty {
            code.removeLast()
        }
    }
    
    func generateCode() {
        Task {
            code = []
            let generated = CodeGeneratorHelper.generateCode()
            for char in generated {
                code.append(char)
                try await Task.sleep(for: .seconds(0.1))
            }
        }
    }
    
    func copy() {
        guard !code.isEmpty else {
            message = "No Code generated"
            
            Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false , block: { [self]_ in 
                message = ""
            })
            return
        }
        
        let pasteboard = UIPasteboard.general
        pasteboard.string = codeString.joined()
        print(codeString.joined())
    }
    
    func past() {
        code = []
        if let pasteboard = UIPasteboard.general.string {
            for char in pasteboard {
                code.append(char)
            }
        }
    }
}

struct GenerateCodeView: View {
    @Environment(\.dismiss) var dismiss
    @State private var viewModel = CodeEntryViewModel()
    
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
                })
                
                ToolbarItem(placement: .navigationBarTrailing, content: {
                    Button("Copy") {
                        viewModel.copy()
                    }
                })
            }
        }
    }
}

struct EnterCodeView: View {
    @Environment(\.dismiss) var dismiss
    @State private var viewModel = CodeEntryViewModel()
    
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
                              .onLongPressGesture(perform: {
                                  viewModel.past()
                              })
                        }
                    }
                     
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 12) {
                        ForEach(1..<10, id: \.self) { number in
                            Button(action: {
                                viewModel.addDigit("\(number)")
                            }, label: {
                                Text("\(number)")
                                    .foregroundStyle(Theme.white)
                                    .font(.largeTitle)
                                    .frame(width: 60, height: 60)
                                    .background(Theme.darkOrange.opacity(0.2))
                                    .clipShape(Circle())
                            })
                        }
                         
                        Spacer()
                        
                        Button(action: {
                            viewModel.addDigit("0")
                        }, label: {
                            Text("0")
                                .foregroundStyle(Theme.white)
                                .font(.largeTitle)
                                .frame(width: 60, height: 60)
                                .background(Theme.darkOrange.opacity(0.2))
                                .clipShape(Circle())
                        })
                        
                        Button(action: {
                            viewModel.deleteLastDigit()
                        },
                        label: {
                            Image(systemName: "delete.left")
                                .foregroundStyle(Theme.white)
                                .font(.largeTitle)
                                .frame(width: 60, height: 60)
                                .background(Theme.myGray.opacity(0.2))
                                .clipShape(Circle())
                        })
                    }
                    .padding(.top, 30)
                }
                
            }
            .navigationTitle("Enter Code")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading, content: {
                    Button("Cancel") {
                        dismiss()
                    }
                })
                
                ToolbarItem(placement: .navigationBarTrailing, content: {
                    Button("Join") {}
                })
            }
        }
    }
}

#Preview {
    EnterCodeView()
        .sheet(isPresented: .constant(true), content: {
            ZStack {
                Theme.background.ignoresSafeArea()
                
                GenerateCodeView()
            }
        })
        .sheet(isPresented: .constant(false), content: {
            ZStack {
                Theme.background.ignoresSafeArea()
                
                EnterCodeView()
            }
        })
}
