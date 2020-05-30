//
//  EKEvent+Extension.swift
//  EKEventKit.Example
//
//  Created by Filip Němeček on 30/04/2020.
//  Copyright © 2020 Filip Němeček. All rights reserved.
//

import UIKit
import EventKit

extension EKEvent {
    var hasGeoLocation: Bool {
        return structuredLocation?.geoLocation != nil
    }
    
    var isBirthdayEvent: Bool {
        return birthdayContactIdentifier != nil
    }
    
    var color: UIColor {
        return UIColor(cgColor: calendar.cgColor)
    }
}
