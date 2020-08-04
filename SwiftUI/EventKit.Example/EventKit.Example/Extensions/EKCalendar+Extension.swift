//
//  EKCalendar+Extension.swift
//  EventKit.Example
//
//  Created by Filip Němeček on 04/08/2020.
//  Copyright © 2020 Filip Němeček. All rights reserved.
//

import SwiftUI
import EventKit

extension EKCalendar: Identifiable {
    public var id: String {
        return self.calendarIdentifier
    }
    
    public var color: Color {
        return Color(UIColor(cgColor: self.cgColor))
    }
    
    public var formattedText: Text {
        return Text("•\u{00a0}")
            .font(.headline)
            .foregroundColor(self.color)
            + Text("\(self.title)")
    }
}
