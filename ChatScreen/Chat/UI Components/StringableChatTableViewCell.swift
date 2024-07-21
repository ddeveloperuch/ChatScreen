//
//  StringableChatTableViewCell.swift
//  ChatScreen
//
//  Created by Developer on 20/07/2024.
//  Copyright © 2024 Developer Software Foundation. All rights reserved.
//

import UIKit

class StringableChatTableViewCell: DeletableCell {
    static let reuseIdentifier = "StringableChatTableViewCellIdentifier"
    
    @IBOutlet weak var contentTextView: UITextView!
    
    // MARK: -
    
    func configure(with message: String) {
        contentTextView.text = message
    }
}
