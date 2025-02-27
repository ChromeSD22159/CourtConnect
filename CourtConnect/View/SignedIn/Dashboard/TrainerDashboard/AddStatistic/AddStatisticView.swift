//
//  AddStatisticView.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 07.02.25.
//
import SwiftUI
 
struct AddStatisticView: View {
    @State var viewModel = AddStatisticViewModel()
    
    var body: some View {
        AnimationBackgroundChange {
            List {
                ListInfomationSection(text: "Please enter the statistics for every player here.  Use the steppers to set the number of 2-point throws, 3-point throws and fouls.  The total number of points is automatically calculated.")
                
                Section {
                    if viewModel.termine.isEmpty {
                        NoAppointmentAvailableView()
                    } else {
                        ForEach(viewModel.termine) { termin in 
                            
                            HStack {
                                Text(termin.startTime.toDateString() + " " + termin.title)
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                                
                                Spacer()
                                
                                Text(TerminType(rawValue: termin.typeString)?.localized ?? "")
                                    .font(.caption2)
                                    .padding(5)
                                    .background {
                                        if viewModel.terminHasOpenMembers(termin: termin) ||
                                           viewModel.terminHasOpenTrainer(termin: termin) {
                                            TerminType(rawValue: termin.typeString) == .game ? Theme.lightOrange : Theme.darkOrange
                                        } else {
                                            Color.gray.opacity(0.8)
                                        }
                                    }
                                    .borderRadius(5)
                            }
                            .font(.footnote)
                            .onTapGesture {
                                viewModel.setTermin(termin: termin)
                            }
                        }
                    }
                }
                .blurrylistRowBackground()
            }
        }
        .sheet(item: $viewModel.selectedTermin) { termin in
            let filteredTeamPlayerList = viewModel.filterTeamPlayer(terminId: termin.id)
            let filteredTeamTrainerList = viewModel.filterTeamTrainer(terminId: termin.id) 
            
            AddStaticSheet(viewModel: viewModel, termin: termin, filteredTeamPlayerList: filteredTeamPlayerList, filteredTeamTrainerList: filteredTeamTrainerList) { termin in
                viewModel.saveStatistics(termin: termin)
            }
            .presentationCornerRadius(25)
            .presentationBackground(Material.ultraThinMaterial)
            .presentationDragIndicator(.visible)
        }
        .refreshable { viewModel.fetchDataFromRemote() }
        .navigationTitle(title: "Statistics")
        .listBackgroundAnimated()
    }
} 

fileprivate struct AddStaticSheet: View {
    let viewModel: AddStatisticViewModel
    let filteredTeamPlayerList: [TeamMemberProfileStatistic]
    let filteredTeamTrainerList: [TeamMemberProfile]
    var termin: Termin
    let onSave: (Termin) -> Void
    
    init(viewModel: AddStatisticViewModel, termin: Termin, filteredTeamPlayerList: [TeamMemberProfileStatistic], filteredTeamTrainerList: [TeamMemberProfile], onSave: @escaping (Termin) -> Void) {
        self.termin = termin
        self.viewModel = viewModel
        self.filteredTeamPlayerList = filteredTeamPlayerList
        self.filteredTeamTrainerList = filteredTeamTrainerList
        self.onSave = onSave
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                Section {
                    HStack(alignment: .center) {
                        Text(termin.title)
                            .font(.headline.bold())
                        
                        Spacer()
                        
                        Text(termin.startTime.toDateString())
                            .font(.headline)
                    }
                    HStack(alignment: .center) {
                        Text(termin.typeString)
                        
                        Spacer()
                    }
                }
                
                Section {
                    if filteredTeamPlayerList.isEmpty {
                        HStack {
                            AllStatisticEneredAvailableView()
                        }
                        .padding()
                        .background(Material.ultraThinMaterial)
                        .borderRadius(15)
                    } else {
                        ForEach(filteredTeamPlayerList, id: \.teamMember.id) { player in
                            MemberRowPlayer(player: player)
                        }
                    }
                } header: {
                    HStack {
                        UpperCasedheadline(text: "Player")
                        Spacer()
                    }
                }
                
                Section {
                    if filteredTeamTrainerList.isEmpty {
                        HStack {
                            AllCoachesConfirmedAvailableView()
                        }
                        .padding()
                        .background(Material.ultraThinMaterial)
                        .borderRadius(15)
                    } else {
                        ForEach(filteredTeamTrainerList, id: \.teamMember.id) { trainer in
                            MemberRowTrainer(trainer: trainer, termin: termin, viewModel: viewModel)
                            /*
                            MemberRowTrainer(trainer: trainer) {
                                //trainerIdsToConfirm.append($0)
                            }
                             */
                        }
                    }
                } header: {
                    HStack {
                        UpperCasedheadline(text: "Coach")
                        Spacer()
                    }
                }
            }
            .scrollIndicators(.hidden)
            .navigationTitle("Add Statistic")
            .navigationBarTitleDisplayMode(.inline)
            .contentMargins(20)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        onSave(termin)
                    }
                }
            }
        }
    }
} 

fileprivate struct MemberRowPlayer: View {
    var player: TeamMemberProfileStatistic
    @State var isExpant = false
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(player.userProfile.fullName)
                Spacer()
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
            .padding()
            .background(Material.ultraThinMaterial)
            .borderRadius(15)
             
            if isExpant {
                VStack {
                    NumberTextFieldRow(description: "2er", icon: .customFigureBasketballFoul, stepperNumber: player.statistic.twoPointAttempts)
                    NumberTextFieldRow(description: "3er", icon: .customBasketball2Fill, stepperNumber: player.statistic.threePointAttempts)
                    NumberTextFieldRow(description: "Fouls", icon: .customBasketball3Fill, stepperNumber: player.statistic.fouls)
                    HStack(spacing: 16) {
                        Image(systemName: "trophy.fill")
                            .font(.title)
                            .frame(minWidth: 40)
                        Spacer()
                        Text("Total Points: \(player.statistic.points)")
                    }
                    
                    ToggleAttendance(toggle: player.statistic.wasThere)
                } .padding([.horizontal, .bottom])
            }
            
        }
        .background(Material.ultraThinMaterial)
        .borderRadius(15)
    }
}

fileprivate struct ToggleAttendance: View {
    @Bindable var toggle: ToggleValue
    var body: some View {
        Toggle("Attendance", isOn: $toggle.value)
    }
}

fileprivate struct NumberTextFieldRow: View {
    let description: String
    let icon: ImageResource
    @Bindable var stepperNumber: StepperNumber
    var body: some View {
        HStack(spacing: 16) {
            Image(icon)
                .font(.title)
                .frame(minWidth: 40)
            Text(description)
            Spacer()
            Text("x\(stepperNumber.number)")
            Stepper(description, value: $stepperNumber.number)
                .labelsHidden()
        }
    }
}

fileprivate struct MemberRowTrainer: View {
    var trainer: TeamMemberProfile
    let termin: Termin
    let viewModel: AddStatisticViewModel
    @State private var isExpant = false
    @State private var isConfirmed = false
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(trainer.userProfile.fullName)
                Spacer()
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
            .padding()
            .background(Material.ultraThinMaterial)
            .borderRadius(15)
             
            if isExpant {
                VStack {
                    Toggle("Attendance", isOn: $isConfirmed)
                        .onChange(of: isConfirmed) {
                            if isConfirmed {
                                viewModel.confirmTrainerAttendance(userAccountId: trainer.teamMember.userAccountId, terminId: termin.id)
                            }
                        }
                }
                .padding([.horizontal, .bottom]) 
            }
            
        }
        .background(Material.ultraThinMaterial)
        .borderRadius(15)
    }
}

#Preview {
    NavigationStack {
        AddStatisticView()
    }
}
