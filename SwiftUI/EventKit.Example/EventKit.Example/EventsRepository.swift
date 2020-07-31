//
//  EventsRepository.swift
//  EventKit.Example
//
//  Created by Filip Němeček on 31/07/2020.
//  Copyright © 2020 Filip Němeček. All rights reserved.
//

import Foundation
import EventKit

typealias Action = () -> ()

class EventsRepository {
    static let shared = EventsRepository()
    
    let eventStore = EKEventStore()
    
    lazy var selectedCalendars = Set([eventStore.defaultCalendarForNewEvents].compactMap({ $0 }))
    
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
            
            let predicate = self.eventStore.predicateForEvents(withStart: Date(), end: weekFromNow, calendars: Array(self.selectedCalendars))
            let events = self.eventStore.events(matching: predicate)
            
            completion(events)
        }) {
            completion(nil)
        }
    }
}


extension TimeInterval {
    static func weeks(_ weeks: Double) -> TimeInterval {
        return weeks * TimeInterval.week
    }
    
    static var week: TimeInterval {
        return 7 * 24 * 60 * 60
    }
}
