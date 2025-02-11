//
//  AddStatisticView.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 07.02.25.
//
import SwiftUI
 
struct AddStatisticView: View {
    @State var viewModel: AddStatisticViewModel
    
    init(teamId: UUID, userId: UUID) {
        self.viewModel = AddStatisticViewModel(teamId: teamId, userId: userId)
    }
    
    var body: some View {
        List {
            ListInfomationSection(text: "Please enter the statistics for every player here.  Use the steppers to set the number of 2-point throws, 3-point throws and fouls.  The total number of points is automatically calculated.") 
            if viewModel.termine.isEmpty {
                ContentUnavailableView("No Appointments", systemImage: "calendar", description: Text("There are no appointments to insert statistics for the players."))
            } else {
                ForEach(viewModel.termine) { termin in
                    HStack {
                        Text(termin.startTime.toDateString() + " " + termin.title)
                            .lineLimit(1)
                            .truncationMode(.tail)
                        
                        Spacer()
                        
                        Text(termin.typeString)
                            .font(.caption2)
                            .padding(5)
                            .background(TerminType(rawValue: termin.typeString) == .game ? Theme.lightOrange : Theme.darkOrange)
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                    }
                    .font(.footnote)
                    .onTapGesture {
                        viewModel.setTermin(termin: termin)
                    }
                }
            }
        }
        .sheet(item: $viewModel.selectedTermin) { termin in
            AddStaticSheet(termin: termin, viewModel: viewModel)
                .presentationCornerRadius(25)
                .presentationBackground(Material.ultraThinMaterial)
                .presentationDragIndicator(.visible)
                .onDisappear {
                    viewModel.saveStatistics(termin: termin)
                }
        }
        .listBackground()
    }
}

fileprivate struct AddStaticSheet: View {
    let termin: Termin
    var viewModel: AddStatisticViewModel
    
    init(termin: Termin, viewModel: AddStatisticViewModel) {
        self.termin = termin
        self.viewModel = viewModel
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
                    ForEach(viewModel.teamPlayer, id: \.teamMember.id) { player in
                        MemberRowPlayer(player: player)
                    }
                } header: {
                    UpperCasedheadline(text: "Player")
                }
                
                Section {
                    ForEach(viewModel.teamTrainer, id: \.teamMember.id) { trainer in
                        MemberRowTrainer(trainer: trainer)
                    }
                } header: {
                    UpperCasedheadline(text: "Trainer")
                }
            }
            .scrollIndicators(.hidden)
            .navigationTitle("Add Statistic")
            .navigationBarTitleDisplayMode(.inline)
            .contentMargins(20)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        viewModel.saveStatistics(termin: termin)
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
            .clipShape(RoundedRectangle(cornerRadius: 15))
             
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
        .clipShape(RoundedRectangle(cornerRadius: 15))
    }
}

fileprivate struct ToggleAttendance: View {
    @Bindable var toggle: ToggleValue
    var body: some View {
        Toggle("Attandance", isOn: $toggle.value)
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
    @State var isExpant = false
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
            .clipShape(RoundedRectangle(cornerRadius: 15))
             
            if isExpant {
                VStack {
                    Toggle("Attandance", isOn: .constant(true))
                } .padding([.horizontal, .bottom])
            }
            
        }
        .background(Material.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 15))
    }
}

#Preview {
    List {
        
        Section {
            VStack(alignment: .leading) {
                Label("Infomation", systemImage: "info")
                    .symbolVariant(.circle.circle)
                
                Text("Please enter the statistics for every player here.  Use the steppers to set the number of 2-point throws, 3-point throws and fouls.  The total number of points is automatically calculated.")
                    .font(.footnote)
            }
            .foregroundStyle(Theme.myGray)
        }
        .listRowBackground(Color.clear)
        
        HStack {
            Text(Date().toDateString())
            Text("Freiburg vs Hamburg")
            Spacer()
            
            Text("Game")
                .font(.caption2)
                .padding(5)
                .background(Theme.darkOrange)
                .clipShape(RoundedRectangle(cornerRadius: 5))
        }
    }
} 

#Preview {
    AddStatisticView(teamId: MockUser.teamId, userId: MockUser.myUserAccount.userId)
}
