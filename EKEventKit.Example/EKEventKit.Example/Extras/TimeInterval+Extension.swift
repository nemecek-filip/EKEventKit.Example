//
//  TimeInterval+Extension.swift
//  EKEventKit.Example
//
//  Created by Filip Němeček on 30/04/2020.
//  Copyright © 2020 Filip Němeček. All rights reserved.
//

import Foundation

extension TimeInterval {
    static func weeks(_ weeks: Double) -> TimeInterval {
        return weeks * TimeInterval.week
    }
    
    static var week: TimeInterval {
        return 7 * 24 * 60 * 60
    }
}
