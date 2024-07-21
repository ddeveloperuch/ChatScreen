//
//  Swinject+Extension.swift
//  ChatScreen
//
//  Created by Developer on 20/07/2024.
//  Copyright © 2024 Developer Software Foundation. All rights reserved.
//

import Swinject

// MARK: - Container

extension Container {
    
    struct `default` {
        
        static let container: Container = {
            return Container()
        }()
        
        static let resolver: Resolver = {
            return container.synchronize()
        }()
    }
}
