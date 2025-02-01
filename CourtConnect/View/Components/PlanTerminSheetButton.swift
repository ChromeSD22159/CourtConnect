//
//  PlanTerminSheetButton.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 01.02.25.
//
import SwiftUI

struct PlanTerminSheetButton: View {
    @State var isSheet = false
    @State var isSheetAnimate = false
    
    @State var title: String = ""
    @State var place: String = ""
    @State var infomation: String = ""
    @State var kind: TerminType = .training
    @State var duration: TerminDuration = .oneTwenty
    
    let onComplete: (Termin) -> Void = {_ in}
    
    var body: some View {
        HStack {
            Label("Plan Termin", systemImage: "calendar")
            Spacer()
        }
        .onTapGesture {
            isSheet.toggle()
        }
        .padding()
        .background(Material.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .padding(.horizontal)
        .sheet(isPresented: $isSheet, onDismiss: {}) {
            NavigationStack {
                ScrollView {
                    LazyVStack {
                        rowSectionInputText(systemName: "at", headline: "Was?", placeholder: "z.B. Mannschaftstraining", text: $title)
                            .zoomFadeIn(delay: 0.15, trigger: $isSheetAnimate)
                        
                        rowSectionInputText(systemName: "location.fill", headline: "Wo?", placeholder: "Spielort", text: $place)
                            .zoomFadeIn(delay: 0.25, trigger: $isSheetAnimate)
                        
                        rowSectionInputText(systemName: "info.circle.fill", headline: "Wichtiges?", placeholder: "z.B. Treffpunkt vor Ort um 10 Uhr", text: $infomation)
                            .zoomFadeIn(delay: 0.35, trigger: $isSheetAnimate)
                        
                        rowSectionKindSelection(systemName: "figure.basketball", headline: "Art?", placeholder: "asdsddasd", terminType: $kind)
                            .zoomFadeIn(delay: 0.45, trigger: $isSheetAnimate)
                        
                        rowSectionDurationSelection(systemName: "clock", headline: "Wie lange?", placeholder: "asdsddasd", terminType: $duration)
                            .zoomFadeIn(delay: 0.55, trigger: $isSheetAnimate)
                        
                        Button("Create Termin") {
                            guard !title.isEmpty else { return }
                            guard !place.isEmpty else { return }
                            guard !infomation.isEmpty else { return }
                            
                            let newTermin = Termin(
                                teamId: UUID(),
                                title: title,
                                place: place,
                                infomation: infomation,
                                typeString: kind.rawValue,
                                durationMinutes: duration.durationMinutes,
                                date: Date(),
                                createdAt: Date(),
                                updatedAt: Date()
                            )
                            
                            onComplete(newTermin)
                        }
                        .buttonStyle(DarkButtonStlye())
                    }
                }
                .onAppear(perform: toggleAnimate)
                .onDisappear(perform: toggleAnimate)
                .listStyle(.insetGrouped)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Text("New Termin")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [
                                        Theme.darkOrange,
                                        Theme.lightOrange
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Image(systemName: "xmark")
                            .onTapGesture {
                                isSheet.toggle()
                            }
                    }
                }
            }
        }
    }
    
    func toggleAnimate() {
        isSheetAnimate.toggle()
    }
    
    @ViewBuilder func rowSectionInputText(systemName: String, headline: LocalizedStringKey, placeholder: LocalizedStringKey, text: Binding<String>) -> some View {
        Section {
            HStack(spacing: 15) {
                IconRoundedRectangle(systemName: systemName)
                
                VStack {
                    TextField(placeholder, text: text, prompt: Text(placeholder))
                    
                    Divider()
                        .frame(height: 1)
                        .padding(.horizontal, 30)
                        .background(Theme.myGray)
                }
                
                Spacer()
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
        } header: {
            HStack {
                Text(headline)
                Spacer()
            }
            .padding(.horizontal)
        }
    }
    
    @ViewBuilder func rowSectionKindSelection(systemName: String, headline: LocalizedStringKey, placeholder: LocalizedStringKey, terminType: Binding<TerminType>) -> some View {
        Section {
            HStack(spacing: 15) {
                IconRoundedRectangle(systemName: systemName)
                
                VStack {
                    Picker(headline, selection: terminType) {
                        ForEach(TerminType.allCases) { type in
                            Text(type.displayName).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Spacer()
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
        } header: {
            HStack {
                Text(headline)
                Spacer()
            }
            .padding(.horizontal)
        }
    }
    
    @ViewBuilder func rowSectionDurationSelection(systemName: String, headline: LocalizedStringKey, placeholder: LocalizedStringKey, terminType: Binding<TerminDuration>) -> some View {
        Section {
            HStack(spacing: 15) {
                IconRoundedRectangle(systemName: systemName)
                
                VStack {
                    Picker(headline, selection: terminType) {
                        ForEach(TerminDuration.allCases) { type in
                            Text(type.rawValue).tag(type)
                                .tint(.red)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Spacer()
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
        } header: {
            HStack {
                Text(headline)
                Spacer()
            }
            .padding(.horizontal)
        }
    }
} 

#Preview("Create Termin") {
    NavigationStack {
        PlanTerminSheetButton()
    }
    .navigationStackTint()
}
