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
}

struct SelectedCalendarsList: View {
    let selectedCalendars: [EKCalendar]
    
    var joinedText: Text {
        var text = Text("")
        
        for calendar in selectedCalendars {
            text = text + Text("\(calendar.title)  ").foregroundColor(calendar.color)
        }
        
        return text
    }
    
    var body: some View {
        joinedText
//        HStack {
//            ForEach(selectedCalendars, id: \.calendarIdentifier) { calendar in
//                HStack {
//                    Circle()
//                        .fill(calendar.color)
//                        .frame(width: 5, height: 5)
//                    Text(calendar.title)
//                    Spacer(minLength: 10)
//                }
//            }
//        }
    }
}
