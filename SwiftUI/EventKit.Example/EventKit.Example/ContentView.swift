//
//  ContentView.swift
//  EventKit.Example
//
//  Created by Filip Němeček on 31/07/2020.
//  Copyright © 2020 Filip Němeček. All rights reserved.
//

import SwiftUI
import EventKit
import Combine

extension EKEvent: Identifiable {
    public var id: String {
        return eventIdentifier
    }
}

struct ContentView: View {
    @State private var showingCalendarChooser = false
    
    @ObservedObject var eventsRepository = EventsRepository.shared
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    if eventsRepository.events?.isEmpty ?? true {
                        Text("No events available for this calendar selection")
                            .font(.headline)
                    }
                    ForEach(eventsRepository.events ?? [], id: \.eventIdentifier) { event in
                        Text(event.title)
                    }
                }
                
                Text("Selected calendars: \(eventsRepository.selectedCalendars?.count ?? 0)")
                    .padding()
                    .font(.caption)
                
                Button(action: {
                    self.showingCalendarChooser = true
                }) {
                    Text("Select calendars")
                }
                .padding()
                .background(Color.orange)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 5))
            }
            .navigationBarTitle("EventKit Example")
            .sheet(isPresented: $showingCalendarChooser) {
                CalendarChooser(calendars: self.$eventsRepository.selectedCalendars, eventStore: EventsRepository.shared.eventStore)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
