//
//  PrimaryButtonStyle.swift
//  EventKit.Example
//
//  Created by Filip Němeček on 04/08/2020.
//  Copyright © 2020 Filip Němeček. All rights reserved.
//

import Foundation
import SwiftUI

struct PrimaryButtonStyle: ButtonStyle {
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(Color.orange)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 5))
        
    }
    
    
}
