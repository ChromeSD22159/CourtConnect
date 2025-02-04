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
    
    var groupedTermine: [String: [Termin]] {
        let dic = Dictionary(grouping: termine, by: {
            $0.date.formatted(.dateTime.day(.twoDigits).month(.twoDigits).year(.twoDigits))
        })
        
        return dic
    }

    var sortedGroupedTermine: [(String, [Termin])] {
       groupedTermine.map { (dateString, termine) in
           (dateString, termine.sorted(by: { $0.date < $1.date })) 
       }.sorted(by: { $0.0 < $1.0 })
    }
    
    @State var showAll = false
    
    var body: some View {
        Section {
            VStack(alignment: .trailing) {
                if !sortedGroupedTermine.isEmpty {
                    LazyVStack(spacing: 25) {
                        if showAll {
                            ForEach(sortedGroupedTermine, id: \.0) { dateString, termine in
                                TerminDayView(dateString: dateString, termine: termine)
                            }
                        } else {
                            if let firstTermin = sortedGroupedTermine.first {
                                TerminDayView(dateString: firstTermin.0, termine: firstTermin.1)

                                if sortedGroupedTermine.count > 1 {
                                    TerminDayView(dateString: sortedGroupedTermine[1].0, termine: sortedGroupedTermine[1].1)
                                }
                            }
                        }
                        
                    }
                    
                    Text(showAll ? "Hide all Termine" : "Show all Termine")
                        .foregroundStyle(Theme.headline)
                        .onTapGesture {
                            withAnimation {
                                showAll.toggle()
                            }
                        }
                } else {
                    TermineUnavailableView()
                }
                
            }
        } header: {
            HStack {
                Text("Termine")
                Spacer()
            }
        }
       
    }
} 

fileprivate struct TerminDayView: View {
    let dateString: String
    let termine: [Termin]
    var body: some View {
        HStack(alignment: .top) {
            Text(dateString)
                .font(.callout.bold())

            VStack {
                ForEach(termine.indices, id: \.self) { index in
                    TerminRow(termin: termine[index])
                }
            }
        }
    }
}

fileprivate struct TerminRow: View {
    let termin: Termin
    var body: some View {
        HStack(alignment: .top) {
            VStack {
                StrokesCircleIcon(systemName: "alarm.fill")
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

                    DateString(date: termin.date, style: .hourMinute)
                        .lineLimit(1)
                        .font(.callout.bold())
                        .foregroundStyle(Theme.myGray)
                }
                
                Text(termin.infomation)
                    .font(.footnote.bold())
                    .lineLimit(3, reservesSpace: true)
            }
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
                        .fill(
                            LinearGradient(colors: [
                                Theme.lightOrange,
                                Theme.darkOrange
                            ], startPoint: .topTrailing, endPoint: .bottomLeading)
                        )
                    
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
        CalendarCard(termine: termine)
    }
    .scrollIndicators(.hidden)
    .padding(.horizontal)
}
