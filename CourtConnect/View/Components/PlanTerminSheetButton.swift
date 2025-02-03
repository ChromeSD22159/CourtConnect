//
//  PlanTerminSheetButton.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 01.02.25.
//
import SwiftUI 
 
struct PlanTerminSheetButton: View {
    @State var viewModel = PlanTerminViewModel()
    
    let userAccount: UserAccount
    
    let onComplete: (Termin) -> Void
    
    var body: some View {
        RowLabelButton(text: "Plan Termin", systemImage: "calendar") {
            viewModel.isSheet.toggle()
        }
        .sheet(isPresented: $viewModel.isSheet, onDismiss: {
            viewModel.resetAnimationState()
        }) {
            SheetStlye(title: "New Termin", detents: [.large], isLoading: $viewModel.isLoading) {
                LazyVStack {
                    rowSectionInputText(systemName: "at", headline: "What?", placeholder: "e.g. team training", text: $viewModel.title)
                        .zoomFadeIn(delay: 0.15, trigger: $viewModel.animateOnAppear)
                    
                    rowSectionInputText(systemName: "location.fill", headline: "Where?", placeholder: "Venue", text: $viewModel.place)
                        .zoomFadeIn(delay: 0.25, trigger: $viewModel.animateOnAppear)
                    
                    rowSectionInputText(systemName: "info.circle.fill", headline: "Important?", placeholder: "e.g. meeting point on site at 10 am.", text: $viewModel.infomation)
                        .zoomFadeIn(delay: 0.35, trigger: $viewModel.animateOnAppear)
                    
                    rowSectionKindSelection(systemName: "figure.basketball", headline: "Kind?", terminType: $viewModel.kind)
                        .zoomFadeIn(delay: 0.45, trigger: $viewModel.animateOnAppear)
                    
                    rowSectionDateSelection(systemName: "calendar.badge.clock", headline: "Date?", date: $viewModel.date)
                        .zoomFadeIn(delay: 0.45, trigger: $viewModel.animateOnAppear)
                    
                    rowSectionDurationSelection(systemName: "clock", headline: "How long?", terminType: $viewModel.duration)
                        .zoomFadeIn(delay: 0.55, trigger: $viewModel.animateOnAppear)
                    
                    Button("Create Termin") {
                        Task {
                            do {
                                if let newTermin = try await viewModel.generateTermin(userAccount: userAccount) { 
                                    onComplete(newTermin)
                                }
                            } catch {
                                print(error)
                            }
                        }
                    }
                    .buttonStyle(DarkButtonStlye())
                }
            }
            .onAppear {
                viewModel.startAnimation() 
            }
        }
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
    
    @ViewBuilder func rowSectionKindSelection(systemName: String, headline: LocalizedStringKey, terminType: Binding<TerminType>) -> some View {
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
    
    @ViewBuilder func rowSectionDateSelection(systemName: String, headline: LocalizedStringKey, date: Binding<Date>) -> some View {
        Section {
            HStack(spacing: 15) {
                IconRoundedRectangle(systemName: systemName)
                
                VStack {
                    DatePicker("Termin Date", selection: date, displayedComponents: [.date, .hourAndMinute])
                        .datePickerStyle(.compact)
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
    
    @ViewBuilder func rowSectionDurationSelection(systemName: String, headline: LocalizedStringKey, terminType: Binding<TerminDuration>) -> some View {
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
    let mockAccount = MockUser.myUserAccount
    NavigationStack {
        PlanTerminSheetButton(userAccount: mockAccount) { _ in
        }
    }
    .navigationStackTint()
} 
