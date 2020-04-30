//
//  DisplaysCalendars.swift
//  EKEventKit.Example
//
//  Created by Filip Němeček on 30/04/2020.
//  Copyright © 2020 Filip Němeček. All rights reserved.
//

import EventKit
import UIKit

protocol DisplaysCalendars {
    func formattedString(for calendars: Set<EKCalendar>) -> NSAttributedString
}

extension DisplaysCalendars {
    private var nonBreakingSpace: String {
        "\u{00a0}"
    }
    
    func formattedString(for calendars: Set<EKCalendar>) -> NSAttributedString {
        let text = NSMutableAttributedString(string: "Selected calendars:  ")
        
        let spacing = String(repeating: " ", count: 3)
        
        for calendar in calendars {
            let attachment = imageStringAttachment(for: calendar, with: 6)
            let imgString = NSAttributedString(attachment: attachment)
            text.append(imgString)
            text.append(NSAttributedString(string: "\(nonBreakingSpace)\(calendar.title)\(spacing)"))
        }
        
        return text
    }
    
    private func imageStringAttachment(for calendar: EKCalendar, with uniformSize: CGFloat) -> NSTextAttachment {
        let image = UIImage(named: "dot")!.withTintColor(UIColor(cgColor: calendar.cgColor))
        let attachment = NSTextAttachment()
        attachment.bounds = CGRect(x: 0, y: 0, width: uniformSize, height: uniformSize)
        attachment.image = image
        return attachment
    }
}
