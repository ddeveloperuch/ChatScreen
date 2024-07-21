//
//  CKTableView.swift
//  ChatScreen
//
//  Created by Developer on 20/07/2024.
//  Copyright © 2024 Developer Software Foundation. All rights reserved.
//

import UIKit

class CKTableView: UITableView {

    // Note: Reloads the data with completion handler that is guaranteed
    // to execute after the entire reload process completes.
    func reloadDataWithCompletion(completion: @escaping () -> Void) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        reloadData()
        CATransaction.commit()
    }
}
