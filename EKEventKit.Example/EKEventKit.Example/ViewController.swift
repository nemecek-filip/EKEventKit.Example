//
//  ViewController.swift
//  EKEventKit.Example
//
//  Created by Filip Němeček on 30/03/2020.
//  Copyright © 2020 Filip Němeček. All rights reserved.
//

import UIKit
import EventKitUI

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet var tableView: UITableView!
    
    let eventStore = EKEventStore()
    
    lazy var selectedCalendars = Set([eventStore.defaultCalendarForNewEvents].compactMap({ $0 }))
    
    var events: [EKEvent]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 300
        
        requestAccess()
    }
    
    func requestAccess() {
        eventStore.requestAccess(to: .event) { (granted, error) in
            if granted {
                self.loadEvents()
            }
        }
    }
    
    func loadEvents() {
        let weekFromNow = Date().advanced(by: TimeInterval.week)
        
        let predicate = eventStore.predicateForEvents(withStart: Date(), end: weekFromNow, calendars: Array(selectedCalendars))
        events = eventStore.events(matching: predicate)
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    @IBAction func selectCalendarTapped(_ sender: Any) {
        let chooser = EKCalendarChooser(selectionStyle: .multiple, displayStyle: .allCalendars, entityType: .event, eventStore: eventStore)
        chooser.delegate = self
        chooser.showsDoneButton = true
        chooser.showsCancelButton = true
        chooser.selectedCalendars = selectedCalendars
        
        let nvc = UINavigationController(rootViewController: chooser)
        
        present(nvc, animated: true, completion: nil)
    }
    
    func showEditViewController(for event: EKEvent) {
        let eventEditViewController = EKEventEditViewController()
        eventEditViewController.eventStore = eventStore
        eventEditViewController.event = event
        eventEditViewController.editViewDelegate = self
        
        present(eventEditViewController, animated: true, completion: nil)
    }
    
    // MARK: tableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let events = events else {
            preconditionFailure("Events must be loaded if numberOfRows isnt zero")
        }
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath) as? EventCell else {
            preconditionFailure("Check cell configuration")
        }
        
        let event = events[indexPath.row]
        
        cell.configure(with: event)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let events = events else {
            preconditionFailure()
        }
        
        defer {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        
        let event = events[indexPath.row]
        
        showEditViewController(for: event)
    }

}

// MARK: EKEventEditViewDelegate

extension ViewController: EKEventEditViewDelegate {
    func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
        dismiss(animated: true, completion: nil)
        
        if action != .canceled {
            DispatchQueue.main.async {
                self.loadEvents()
            }
        }
    }
}

extension ViewController: EKCalendarChooserDelegate {
    func calendarChooserDidFinish(_ calendarChooser: EKCalendarChooser) {
        dismiss(animated: true, completion: nil)
        
        selectedCalendars = calendarChooser.selectedCalendars
        loadEvents()
    }
    
    func calendarChooserDidCancel(_ calendarChooser: EKCalendarChooser) {
        dismiss(animated: true, completion: nil)
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
