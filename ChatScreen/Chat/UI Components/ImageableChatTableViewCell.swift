//
//  ImageableChatTableViewCell.swift
//  ChatScreen
//
//  Created by Developer on 20/07/2024.
//  Copyright © 2024 Developer Software Foundation. All rights reserved.
//

import UIKit

class ImageableChatTableViewCell: DeletableCell {
    static let reuseIdentifier = "ImageableChatTableViewCellIdentifier"
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: -
    
    func configure(with images: [UIImage]) {
        self.internalImages = images
    }
    
    // MARK: - Private
    
    private var internalImages = [UIImage]()
}

extension ImageableChatTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return internalImages.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ImageableCollectionViewCell.reuseIdentifier, for: indexPath
        ) as! ImageableCollectionViewCell
        cell.configure(with: internalImages[indexPath.item])
        return cell
    }
}
