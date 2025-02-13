//
//  CalendarCard.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 04.02.25.
//
import SwiftUI
import Foundation

struct CalendarCard: View {
    let termine: [Termin]
    let editable: Bool
    let title: String
    
    let onChanged: () -> Void
    
    init(title: String = "Termine", termine: [Termin], editable: Bool, onChanged: @escaping () -> Void = {}) {
        self.title = title
        self.termine = termine
        self.editable = editable
        self.onChanged = onChanged
    }
    
    var groupedTermine: [String: [Termin]] {
        let dic = Dictionary(grouping: termine, by: {
            $0.startTime.toDateString()
        })
        return dic
    }

    var sortedGroupedTermine: [(String, [Termin])] {
       groupedTermine.map { (dateString, termine) in
           (dateString, termine.sorted(by: { $0.startTime < $1.startTime }))
       }.sorted(by: { $0.0 < $1.0 })
    }
    
    @State var showAll = false
     
    var body: some View {
        Section {
            VStack(alignment: .trailing) {
                if !sortedGroupedTermine.isEmpty {
                    LazyVStack(spacing: 25) {
                        ForEach(showAll ? sortedGroupedTermine : Array(sortedGroupedTermine.prefix(2)), id: \.0) { dateString, termin in
                            TerminDayView(dateString: dateString, termine: termin, editable: editable, onChanged: onChanged)
                        }
                    }
                    ShowModeTextButton(showAll: $showAll)
                } else {
                    TermineUnavailableView()
                }
            }
        } header: {
            HStack {
                UpperCasedheadline(text: .init(title.uppercased()))
                Spacer()
            }
        }
       
    }
}
 
fileprivate struct TerminDayView: View {
    let dateString: String
    let termine: [Termin]
    let editable: Bool
    let onChanged: () -> Void
    var body: some View {
        HStack(alignment: .top) {
            Text(dateString)
                .font(.callout.bold())

            VStack {
                ForEach(termine.indices, id: \.self) { index in
                    TerminRow(termin: termine[index], editable: editable, onChanged: onChanged)
                }
            }
        }
    }
}

fileprivate struct TerminRow: View {
    let termin: Termin
    let editable: Bool
    let onChanged: () -> Void
    
    @State var isSheeet: Bool = false
    @State var selectedTermin: Termin?
  
    var body: some View {
        HStack(alignment: .top) {
            VStack {
                // square.and.pencil
                StrokesCircleIcon(systemName: editable ? "pencil" : "alarm.fill")
                    .padding(.horizontal, 20)

                Line()
                    .stroke(style: StrokeStyle(lineWidth: 1, dash: [5]))
                    .frame(width: 1, height: 50)
            }

            VStack(alignment: .leading) {
                Text(termin.title)
                    .lineLimit(1)
                    .fontWeight(.bold)

                HStack {
                    Text(termin.place)
                        .lineLimit(1)
                        .font(.callout.bold())
                        .foregroundStyle(Theme.myGray)

                    Spacer()

                    DateString(date: termin.startTime, style: .hourMinute)
                        .lineLimit(1)
                        .font(.callout.bold())
                        .foregroundStyle(Theme.myGray)
                }
                
                Text(termin.infomation)
                    .font(.footnote.bold())
                    .lineLimit(3, reservesSpace: true)
            }
        }
        .onTapGesture {
            if editable {
                selectedTermin = termin
            } else {
                isSheeet.toggle()
            }
        }
        .errorAlert()
        .sheet(item: $selectedTermin) {
            selectedTermin = nil
        } content: { termin in
            EditTerminSheetButton(termin: termin)
                .onDisappear {
                    onChanged()
                }
        }
        .sheet(isPresented: $isSheeet) {
            TerminSheet(terminId: termin.id)
        }
    }
}

fileprivate struct StrokesCircleIcon: View {
    let systemName: String
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Image(systemName: systemName)
            .font(.headline)
            .padding(10)
            .foregroundColor(Theme.white.opacity(0.85))
            .background {
                ZStack {
                    Circle()
                        .fill(Theme.topTrailingbottomLeadingGradient)
                    
                    Circle()
                        .stroke(colorScheme == .dark ? Theme.white.opacity(0.25) : Theme.myGray.opacity(0.25), lineWidth: 4)
                        .stroke(colorScheme == .dark ? Theme.myGray.opacity(0.25) : Theme.white.opacity(0.25), lineWidth: 8)
                        .stroke(colorScheme == .dark ? Theme.myGray.opacity(0.25) : Theme.white.opacity(0.25), lineWidth: 12)
                }
            }
    }
}   

#Preview {
    let termine = MockTermine.termine
    ScrollView(.vertical) {
        CalendarCard(termine: termine, editable: true)
    }
    .scrollIndicators(.hidden)
    .padding(.horizontal)
}
