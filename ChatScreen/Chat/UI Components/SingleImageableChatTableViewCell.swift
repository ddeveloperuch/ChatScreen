//
//  SingleImageableChatTableViewCell.swift
//  ChatScreen
//
//  Created by Developer on 20/07/2024.
//  Copyright © 2024 Developer Software Foundation. All rights reserved.
//

import UIKit

class SingleImageableChatTableViewCell: DeletableCell {
    static let reuseIdentifier = "SingleImageableChatTableViewCellIdentifier"
    
    @IBOutlet weak var singleImageView: UIImageView!
    
    // MARK: -
    
    func configure(with image: UIImage) {
        singleImageView.image = image
    }
}
