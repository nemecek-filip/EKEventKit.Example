//
//  EventsRepository.swift
//  EventKit.Example
//
//  Created by Filip Němeček on 31/07/2020.
//  Copyright © 2020 Filip Němeček. All rights reserved.
//

import Foundation
import EventKit
import SwiftUI
import Combine

typealias Action = () -> ()

class EventsRepository: ObservableObject {
    static let shared = EventsRepository()
    
    private var subscribers: Set<AnyCancellable> = []
    
    let eventStore = EKEventStore()
    
    @Published var selectedCalendars: Set<EKCalendar>?
    
    @Published var events: [EKEvent]?
    
    private init() {
        selectedCalendars = Set([eventStore.defaultCalendarForNewEvents].compactMap({ $0 }))
        
        $selectedCalendars.sink { [weak self] (calendars) in
            self?.loadEvents { (events) in
                DispatchQueue.main.async {
                    self?.events = events
                }
            }
        }.store(in: &subscribers)
    }
    
    func requestAccess(onGranted: @escaping Action, onDenied: @escaping Action) {
        eventStore.requestAccess(to: .event) { (granted, error) in
            if granted {
                onGranted()
            } else {
                onDenied()
            }
        }
    }
    
    func loadEvents(completion: @escaping (([EKEvent]?) -> Void)) {
        requestAccess(onGranted: {
            let weekFromNow = Date().advanced(by: TimeInterval.week)
            
            let predicate = self.eventStore.predicateForEvents(withStart: Date(), end: weekFromNow, calendars: Array(self.selectedCalendars ?? []))
            
            let events = self.eventStore.events(matching: predicate)
            
            completion(events)
        }) {
            completion(nil)
        }
    }
}
