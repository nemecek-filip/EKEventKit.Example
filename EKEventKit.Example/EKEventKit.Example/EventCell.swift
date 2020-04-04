//
//  EventCell.swift
//  EKEventKit.Example
//
//  Created by Filip Němeček on 30/03/2020.
//  Copyright © 2020 Filip Němeček. All rights reserved.
//

import UIKit
import EventKit

class EventCell: UITableViewCell {
    @IBOutlet var calendarColorView: UIView!
    @IBOutlet var eventTitleLabel: UILabel!
    @IBOutlet var eventDateLabel: UILabel!
    @IBOutlet var eventDurationLabel: UILabel!
    @IBOutlet var mapIcon: UIImageView!
    
    private static var relativeDateFormatter: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.dateTimeStyle = .named
        return formatter
    }()
    
    private static var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()
    
    func configure(with event: EKEvent) {
        eventTitleLabel.text = event.title
        calendarColorView.backgroundColor = UIColor(cgColor: event.calendar.cgColor)
        eventDurationLabel.text = event.isAllDay ? "all day" : formatDate(forNonAllDayEvent: event)
        eventDateLabel.text = EventCell.relativeDateFormatter.localizedString(for: event.startDate, relativeTo: Date()).uppercased()
        mapIcon.isHidden = !event.hasGeoLocation
    }
    
    private func formatDate(forNonAllDayEvent event: EKEvent) -> String {
        return "\(EventCell.dateFormatter.string(from: event.startDate)) - \(EventCell.dateFormatter.string(from: event.endDate))"
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
