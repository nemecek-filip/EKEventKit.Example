//
//  ViewController.swift
//  EKEventKit.Example
//
//  Created by Filip Němeček on 30/03/2020.
//  Copyright © 2020 Filip Němeček. All rights reserved.
//

import UIKit
import EventKitUI

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, DisplaysCalendars {
    @IBOutlet var tableView: UITableView!
    @IBOutlet var footerLabel: UILabel!
    
    let eventStore = EKEventStore()
    
    lazy var selectedCalendars = Set([eventStore.defaultCalendarForNewEvents].compactMap({ $0 }))
    
    var events: [EKEvent]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        requestAccess()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        // autosize table view footer
        if let footer = tableView.tableFooterView {
            let newSize = footer.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
            footer.frame.size.height = newSize.height
        }
    }
    
    func requestAccess() {
        eventStore.requestAccess(to: .event) { (granted, error) in
            if granted {
                DispatchQueue.main.async {
                    self.loadSelectedCalendars(using: self.eventStore)
                    
                    self.loadEvents()
                    
                    self.displaySelectedCalendars()
                }
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
    
    func loadSelectedCalendars(using eventStore: EKEventStore) {
        if let identifiers = UserDefaults.standard.stringArray(forKey: "CalendarIdentifiers") {
            let calendars = eventStore.calendars(for: .event).filter({ identifiers.contains($0.calendarIdentifier) })
            guard !calendars.isEmpty else { return }
            selectedCalendars = Set(calendars)
        }
    }
    
    func saveSelectedCalendars() {
        let identifiers = selectedCalendars.map({ $0.calendarIdentifier })
        UserDefaults.standard.set(identifiers, forKey: "CalendarIdentifiers")
    }
    
    func createNewCalendar(withName name: String) {
        let calendar = EKCalendar(for: .event, eventStore: eventStore)
        calendar.title = name
        calendar.cgColor = UIColor.purple.cgColor
        
        guard let source = bestPossibleEKSource() else {
            return // source is required, otherwise calendar cannot be saved
        }
        
        calendar.source = source
        
        try! eventStore.saveCalendar(calendar, commit: true)
    }
    
    func bestPossibleEKSource() -> EKSource? {
        let `default` = eventStore.defaultCalendarForNewEvents?.source
        let iCloud = eventStore.sources.first(where: { $0.title == "iCloud" }) // this is fragile, user can rename the source
        let local = eventStore.sources.first(where: { $0.sourceType == .local })
        
        return `default` ?? iCloud ?? local
    }
    
    func showNewEntitySelection() {
        let ac = UIAlertController(title: "New...", message: nil, preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "Event", style: .default, handler: { (_) in
            self.showEditViewController(for: nil)
        }))
        ac.addAction(UIAlertAction(title: "Calendar", style: .default, handler: { (_) in
            self.showNewCalendarDialog()
        }))
        
        ac.addCancelAction()
        
        present(ac, animated: true)
    }
    
    func showNewCalendarDialog() {
        let ac = UIAlertController(title: "Create new calendar", message: nil, preferredStyle: .alert)
        ac.addTextField { (textField) in
            textField.placeholder = "Calendar name"
            textField.autocapitalizationType = .words
        }
        ac.addAction(UIAlertAction(title: "Save", style: .default, handler: { (_) in
            guard let name = ac.textFields!.first!.text else { return }
            
            self.createNewCalendar(withName: name)
        }))
        
        ac.addCancelAction()
        
        present(ac, animated: true)
    }
    
    @IBAction func addButtonTapped(_ sender: Any) {
        showNewEntitySelection()
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
    
    @IBAction func githubButtonTapped(_ sender: Any) {
        UIApplication.shared.open(URL(string: "https://github.com/nemecek-filip")!, options: [:], completionHandler: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showMap", let event = sender as? EKEvent {
            let nvc = segue.destination as! UINavigationController
            let mapController = nvc.topViewController as! MapViewController
            mapController.title = event.title
            mapController.coordinate = event.structuredLocation?.geoLocation?.coordinate
        }
    }
    
    func showEditViewController(for event: EKEvent?) {
        let eventEditViewController = EKEventEditViewController()
        eventEditViewController.eventStore = eventStore
        if let event = event {
            eventEditViewController.event = event // when set to nil the controller would not display anything
        }
        eventEditViewController.editViewDelegate = self
        
        present(eventEditViewController, animated: true, completion: nil)
    }
    
    func showOptions(for event: EKEvent) {
        let ac = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "Show map", style: .default, handler: { (_) in
            self.performSegue(withIdentifier: "showMap", sender: event)
        }))
        ac.addAction(UIAlertAction(title: "Edit", style: .default, handler: { (_) in
            self.showEditViewController(for: event)
        }))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(ac, animated: true)
    }
    
    func displaySelectedCalendars() {
        guard !selectedCalendars.isEmpty else {
            footerLabel.text = nil
            return
        }
        
        footerLabel.attributedText = formattedString(for: selectedCalendars)
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
        
        if event.hasGeoLocation {
            showOptions(for: event)
        } else {
            showEditViewController(for: event)
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
        -> UISwipeActionsConfiguration? {
        guard let events = events else {
            preconditionFailure()
        }
        
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { (_, _, completionHandler) in
            let event = events[indexPath.row]
            self.deleteEventWithConfirmation(event: event, at: indexPath)
            completionHandler(true)
        }
        
        deleteAction.image = UIImage(systemName: "trash")
        deleteAction.backgroundColor = .systemRed
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        return configuration
    }

    
    func deleteEventWithConfirmation(event: EKEvent, at indexPath: IndexPath) {
        let ac = UIAlertController(title: "Confirm delete", message: "This will delete: \(event.title ?? "No title") from calendar \(event.calendar.title)", preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (_) in
            do {
                try self.eventStore.remove(event, span: .thisEvent)
                self.events?.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .fade)
            } catch {
                print(error)
            }
        }))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(ac, animated: true)
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

// MARK: EKCalendarChooserDelegate

extension ViewController: EKCalendarChooserDelegate {
    func calendarChooserDidFinish(_ calendarChooser: EKCalendarChooser) {
        dismiss(animated: true, completion: nil)
        
        selectedCalendars = calendarChooser.selectedCalendars
        saveSelectedCalendars()
        displaySelectedCalendars()
        loadEvents()
    }
    
    func calendarChooserDidCancel(_ calendarChooser: EKCalendarChooser) {
        dismiss(animated: true, completion: nil)
    }
}




