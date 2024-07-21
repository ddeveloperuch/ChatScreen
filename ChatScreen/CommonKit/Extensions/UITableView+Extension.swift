//
//  UITableView+Extension.swift
//  ChatScreen
//
//  Created by Developer on 20/07/2024.
//  Copyright © 2024 Developer Software Foundation. All rights reserved.
//

import UIKit

extension UITableView {

    func indexPathExists(indexPath: IndexPath) -> Bool {
        
        guard indexPath.section < numberOfSections,
              indexPath.row < numberOfRows(inSection: indexPath.section) else {
            return false
        }
        return true
    }
}
