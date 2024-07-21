//
//  Array+Extension.swift
//  ChatScreen
//
//  Created by Developer on 20/07/2024.
//  Copyright © 2024 Developer Software Foundation. All rights reserved.
//

import Foundation

extension Array where Element: Equatable {
    
    subscript (safe index: Int) -> Element? {
        return indices ~= index ? self[index] : nil
    }
}
