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
    @IBOutlet var footerLabel: UILabel!
    
    let eventStore = EKEventStore()
    
    private let nonBreakingSpace = "\u{00a0}"
    
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
                self.loadEvents()
                
                self.displaySelectedCalendars()
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
    
    @IBAction func addButtonTapped(_ sender: Any) {
        showEditViewController(for: nil)
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
    
    func showEditViewController(for event: EKEvent?) {
        let eventEditViewController = EKEventEditViewController()
        eventEditViewController.eventStore = eventStore
        if let event = event {
            eventEditViewController.event = event // when setting to nil the controller would not display anything
        }
        eventEditViewController.editViewDelegate = self
        
        present(eventEditViewController, animated: true, completion: nil)
    }
    
    func displaySelectedCalendars() {
        guard !selectedCalendars.isEmpty else {
            footerLabel.text = nil
            return
        }
        
        let text = NSMutableAttributedString(string: "Selected calendars:  ")
        
        let spacing = String(repeating: " ", count: 3)
        
        for calendar in selectedCalendars {
            let attachment = imageStringAttachment(for: calendar, with: footerLabel.bounds.height / 2)
            let imgString = NSAttributedString(attachment: attachment)
            text.append(imgString)
            text.append(NSAttributedString(string: "\(nonBreakingSpace)\(calendar.title)\(spacing)"))
        }
        
        footerLabel.attributedText = text
    }
    
    private func imageStringAttachment(for calendar: EKCalendar, with uniformSize: CGFloat) -> NSTextAttachment {
        let image = UIImage(named: "dot")!.withTintColor(UIColor(cgColor: calendar.cgColor))
        let attachment = NSTextAttachment()
        attachment.bounds = CGRect(x: 0, y: 0, width: uniformSize, height: uniformSize)
        attachment.image = image
        return attachment
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

extension ViewController: EKCalendarChooserDelegate {
    func calendarChooserDidFinish(_ calendarChooser: EKCalendarChooser) {
        dismiss(animated: true, completion: nil)
        
        selectedCalendars = calendarChooser.selectedCalendars
        displaySelectedCalendars()
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
