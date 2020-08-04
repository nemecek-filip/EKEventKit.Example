//
//  SelectedCalendarsList.swift
//  EventKit.Example
//
//  Created by Filip Němeček on 01/08/2020.
//  Copyright © 2020 Filip Němeček. All rights reserved.
//

import EventKit
import SwiftUI

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

struct SelectedCalendarsList: View {
    let selectedCalendars: [EKCalendar]
    
    var joinedText: Text {
        var text = Text("")
        
        for calendar in selectedCalendars {
            text = text + calendar.formattedText + Text("  ")
        }
        
        return text
    }
    
    var body: some View {
        joinedText.foregroundColor(.secondary)
    }
}
