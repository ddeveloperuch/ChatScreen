//
//  CKTextView.swift
//  ChatScreen
//
//  Created by Developer on 20/07/2024.
//  Copyright © 2024 Developer Software Foundation. All rights reserved.
//

import UIKit

class CKTextView: UITextView {

    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }

    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        get {
            guard let color = layer.borderColor else {
                return nil
            }
            return UIColor(cgColor: color)
        }
        set {
            guard let uiColor = newValue else {
                return
            }
            layer.borderColor = uiColor.cgColor
        }
    }
}
