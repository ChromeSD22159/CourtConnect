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

struct TerminSheet: View {
    let viewModel: TerminSheetViewModel
    
    init(terminId: UUID) {
        self.viewModel = TerminSheetViewModel(terminId: terminId)
    }
    
    var body: some View {
        NavigationStack {
              
            Map(initialPosition: viewModel.position, interactionModes: [.zoom, .pan]) {
                ForEach(viewModel.locations) { location in
                    Annotation("", coordinate: location.coordinates, anchor: .bottom) {
                        ZStack {
                            Circle()
                                .foregroundStyle(Theme.lightOrange.opacity(0.5))
                                .frame(width: 60, height: 60)
                            
                            Image(systemName: "basketball.fill")
                                .symbolEffect(.breathe)
                                .padding(10)
                                .foregroundStyle(.white)
                                .background(Theme.lightOrange)
                                .clipShape(Circle())
                        }
                    }
                }
            }
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
                        Text(viewModel.terminData.termin.startTime.toDateString())
                        Spacer()
                        Text(viewModel.terminData.termin.startTime.toTimeString())
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
                    Text(viewModel.terminData.termin.startTime.toDateString())
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
    ZStack {
        Circle()
            .foregroundStyle(Theme.lightOrange.opacity(0.5))
            .frame(width: 60, height: 60)
            
        
        Image(systemName: "basketball.fill")
            .symbolEffect(.breathe)
            .padding(10)
            .foregroundStyle(.white, .red)
            .background(Theme.lightOrange)
            .clipShape( Circle() )
            
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
