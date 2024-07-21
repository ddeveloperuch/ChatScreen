//
//  main.swift
//  ChatScreen
//
//  Created by Developer on 20/07/2024.
//  Copyright © 2024 Developer Software Foundation. All rights reserved.
//

import UIKit
import Swinject

let logger = Logger()

// MARK: - Private

private let container = Container.default.container

CKKeyboardManagerFactory.register(with: container)
CKNotificationCenterFactory.register(with: container)
ChatViewModelFactory.register(with: container)

let _ = UIApplicationMain(CommandLine.argc, CommandLine.unsafeArgv, nil, NSStringFromClass(AppDelegate.self))
