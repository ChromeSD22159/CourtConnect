//
//  EditTerminSheetButton.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 11.02.25.
//
import SwiftUI

struct EditTerminSheetButton: View {
    @Environment(\.dismiss) var dismiss
    @State var viewModel: EditTerminViewModel
    
    init(termin: Termin) {
        self.viewModel = EditTerminViewModel(termin: termin)
    }
    
    var body: some View {
        SheetStlye(title: "Edit Termin", detents: [.large], isLoading: $viewModel.isLoading) {
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
                    .zoomFadeIn(delay: 0.55, trigger: $viewModel.animateOnAppear)
                
                rowSectionDurationSelection(systemName: "clock", headline: "How long?", terminType: $viewModel.duration)
                    .zoomFadeIn(delay: 0.65, trigger: $viewModel.animateOnAppear)
                
                HStack {
                    Button("Delete Termin") {
                        Task {
                            do {
                                try await viewModel.deleteTermin()
                                dismiss()
                            } catch {
                                ErrorHandlerViewModel.shared.handleError(error: error)
                                throw error
                            }
                        }
                    }
                    .buttonStyle(DarkButtonStlye())
                    .zoomFadeIn(delay: 0.75, trigger: $viewModel.animateOnAppear)
                    
                    Button("Save Termin") {
                        Task {
                            do {
                                try await viewModel.saveTermin()
                                dismiss()
                            } catch {
                                ErrorHandlerViewModel.shared.handleError(error: error)
                                throw error
                            }
                        }
                    }
                    .buttonStyle(DarkButtonStlye())
                    .zoomFadeIn(delay: 0.75, trigger: $viewModel.animateOnAppear)
                }
            }
        }
        .onChange(of: viewModel.place, { oldValue, newValue in
            print(GeoCoderHelper.getAddress(address: newValue))
        })
        .onAppear {
            viewModel.inizializeAuth()
            viewModel.startAnimation()
        }
    }
    
    @ViewBuilder func rowSectionInputText(systemName: String, headline: String, placeholder: String, text: Binding<String>) -> some View {
        Section {
            HStack(spacing: 15) {
                IconRoundedRectangle(systemName: systemName, background: Material.ultraThinMaterial)
                
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
                UpperCasedheadline(text: headline)
                Spacer()
            }
            .padding(.horizontal)
        }
    }
    
    @ViewBuilder func rowSectionKindSelection(systemName: String, headline: String, terminType: Binding<TerminType>) -> some View {
        Section {
            HStack(spacing: 15) {
                IconRoundedRectangle(systemName: systemName, background: Material.ultraThinMaterial)
                
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
                UpperCasedheadline(text: headline)
                Spacer()
            }
            .padding(.horizontal)
        }
    }
    
    @ViewBuilder func rowSectionDateSelection(systemName: String, headline: String, date: Binding<Date>) -> some View {
        Section {
            HStack(spacing: 15) {
                IconRoundedRectangle(systemName: systemName, background: Material.ultraThinMaterial)
                
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
                UpperCasedheadline(text: headline)
                Spacer()
            }
            .padding(.horizontal)
        }
    }
    
    @ViewBuilder func rowSectionDurationSelection(systemName: String, headline: String, terminType: Binding<TerminDuration>) -> some View {
        Section {
            HStack(spacing: 15) {
                IconRoundedRectangle(systemName: systemName, background: Material.ultraThinMaterial)
                
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
                UpperCasedheadline(text: headline)
                Spacer()
            }
            .padding(.horizontal)
        }
    }
}
