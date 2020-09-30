//
//  EKEvent+Extension.swift
//  EventKit.Example
//
//  Created by Filip Němeček on 01/08/2020.
//  Copyright © 2020 Filip Němeček. All rights reserved.
//

import EventKit
import SwiftUI

extension EKEvent {
    // This did not work properly and caused wrong event to be used in ForEach
//    public var id: String {
//        return eventIdentifier
//    }
    
    var color: Color {
        return Color(UIColor(cgColor: self.calendar.cgColor))
    }
}
