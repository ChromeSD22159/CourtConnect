//
//  TerminSheet.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 06.02.25.
//
import MapKit
import SwiftUI

struct TerminSheetData {
    var termin: Termin
    var confirmdUser: [String]
}

@Observable @MainActor class TerminSheetViewModel {
    private let repository: BaseRepository
    var scrollPosition: ScrollPosition
    var position: MapCameraPosition
    var terminData: TerminSheetData
    private let terminId: UUID
    
    init(terminId: UUID) {
        self.terminId = terminId
        self.repository = Repository.shared
        self.scrollPosition = ScrollPosition()
        
        self.position  = MapCameraPosition.region(
            GeoCoderHelper.getAddress(address: "Greutwiesenstraße 17, 79787 Lauchringen")!
        )
        
        self.terminData = TerminSheetData(termin: MockTermine.termine.first!, confirmdUser: [])
        
        self.getTermin()
    }
    
    func getTermin() {
        do {
            if let termin = try repository.teamRepository.getTermineBy(id: terminId) {
                self.terminData.termin = termin
                
                self.position  = MapCameraPosition.region(
                    GeoCoderHelper.getAddress(address: termin.place) ?? GeoCoderHelper.getAddress(address: "Greutwiesenstraße 17, 79787 Lauchringen")!
                )
                 
                self.terminData.confirmdUser = try repository.teamRepository.getTeamConfirmedAttendances(for: termin.id)
            }
        } catch {
            print(error)
        }
    }
}

struct TerminSheet: View {
    let viewModel: TerminSheetViewModel
    
    init(terminId: UUID) {
        self.viewModel = TerminSheetViewModel(terminId: terminId)
    }
    
    var body: some View {
        NavigationStack {
            Map(initialPosition: viewModel.position, interactionModes: [.rotate, .zoom])
                .mapStyle(.standard)
                .navigationTitle("Termin")
                .navigationBarTitleDisplayMode(.inline)
                .overlay(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: 15) {
                        VStack(alignment: .leading) {
                            Text(viewModel.terminData.termin.title)
                                .font(.title)
                            
                            Text(viewModel.terminData.termin.place)
                                .font(.subheadline)
                                .padding(.bottom, 15)
                            
                            Text("Planned takes: " + viewModel.terminData.termin.durationMinutes.formatted() + " mins.")
                        }
                        .padding([.horizontal, .top])
                        
                        HStack {
                            Text(viewModel.terminData.termin.startTime.formatted(.dateTime.day(.twoDigits).month(.twoDigits).year(.twoDigits)))
                            Spacer()
                            Text(viewModel.terminData.termin.startTime.formatted(.dateTime.hour().minute()) + "Uhr")
                        }
                        .padding()
                        .background(Material.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                    }
                    .background(Material.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .padding()
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Text(viewModel.terminData.termin.startTime.formatted(.dateTime.day(.twoDigits).month(.twoDigits).year(.twoDigits)))
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Menu {
                            ForEach(viewModel.terminData.confirmdUser, id: \.self) { user in
                                Text(user)
                            }
                        } label: {
                            HStack {
                                Image(systemName: "person.3.fill")
                                Text("\(viewModel.terminData.confirmdUser.count)")
                            }
                        }
                    }
                }
        }
        .presentationDragIndicator(.visible)
        .presentationDetents([.medium ,.large])
        .presentationBackground(Material.ultraThinMaterial)
        .presentationCornerRadius(25)
    }
}
 
#Preview {
    @Previewable @State var isSheeet: Bool = true
     
    Button("test") {
        
    }
    .sheet(isPresented: $isSheeet) {
        TerminSheet(terminId: MockTermine.termine.first!.id)
    }
}
