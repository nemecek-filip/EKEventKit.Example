//
//  UIAlertController+Extension.swift
//  EKEventKit.Example
//
//  Created by Filip Němeček on 30/08/2020.
//  Copyright © 2020 Filip Němeček. All rights reserved.
//

import UIKit

extension UIAlertController {
    func addCancelAction() {
        addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
    }
}
