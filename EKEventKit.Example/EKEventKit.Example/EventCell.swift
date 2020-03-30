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
    
    private static var dateFormatter: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.dateTimeStyle = .named
        return formatter
    }()
    
    func configure(with event: EKEvent) {
        eventTitleLabel.text = event.title
        calendarColorView.backgroundColor = UIColor(cgColor: event.calendar.cgColor)
        eventDurationLabel.text = event.isAllDay ? "all day" : ""
        eventDateLabel.text = EventCell.dateFormatter.localizedString(for: event.startDate, relativeTo: Date()).uppercased()
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
