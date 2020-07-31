//
//  ContentView.swift
//  EventKit.Example
//
//  Created by Filip Němeček on 31/07/2020.
//  Copyright © 2020 Filip Němeček. All rights reserved.
//

import SwiftUI
import EventKit

extension EKEvent: Identifiable {
    public var id: String {
        return eventIdentifier
    }
}

struct ContentView: View {
    @State private var events = [EKEvent]()
    
    @State private var selectedCalendars: Set<EKCalendar>?
    
    @State private var showingCalendarChooser = false
    
    func loadEvents() {
        EventsRepository.shared.loadEvents { (events) in
            if let events = events {
                self.events = events
            }
        }
    }
    
    func selectCalendars() {
        
    }
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    if events.isEmpty {
                        Text("No events available for this calendar selection")
                            .font(.headline)
                    }
                    ForEach(events, id: \.eventIdentifier) { event in
                        Text(event.title)
                    }
                }
                
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
            .onAppear(perform: loadEvents)
            .sheet(isPresented: $showingCalendarChooser) {
                CalendarChooser(calendars: self.$selectedCalendars, eventStore: EventsRepository.shared.eventStore)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
