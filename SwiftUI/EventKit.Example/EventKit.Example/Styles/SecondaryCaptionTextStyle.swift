//
//  SecondaryCaptionTextStyle.swift
//  EventKit.Example
//
//  Created by Filip Němeček on 04/08/2020.
//  Copyright © 2020 Filip Němeček. All rights reserved.
//

import Foundation
import SwiftUI

struct SecondaryCaptionTextStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.caption)
            .foregroundColor(.secondary)
    }
}
