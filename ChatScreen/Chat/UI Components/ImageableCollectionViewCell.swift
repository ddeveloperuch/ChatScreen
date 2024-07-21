//
//  ImageableCollectionViewCell.swift
//  ChatScreen
//
//  Created by Developer on 20/07/2024.
//  Copyright © 2024 Developer Software Foundation. All rights reserved.
//

import UIKit

class ImageableCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "ImageableCollectionViewCellIdentifier"
    
    @IBOutlet weak var imageView: UIImageView!
    
    // MARK: -
    
    func configure(with image: UIImage) {
        imageView.image = image
    }
}
