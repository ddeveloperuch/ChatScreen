//
//  CKNotificationCenter.swift
//  ChatScreen
//
//  Created by Developer on 20/07/2024.
//  Copyright © 2024 Developer Software Foundation. All rights reserved.
//

import Combine
import Foundation
import Swinject

protocol CKNotificationCenter {
    
    func notification(name: String) -> AnyPublisher<Notification, Never>
    func notification(name: Notification.Name) -> AnyPublisher<Notification, Never>
}

class CKNotificationCenterFactory {
    public static func register(with container: Container) {
        container.register(CKNotificationCenter.self) { _ in
            return NotificationCenterImpl()
        }.inObjectScope(.container)
    }
}

fileprivate final class NotificationCenterImpl: CKNotificationCenter {
    
    // MARK: - Lifecycle

    init() {
        logger.debug("NotificationCenterImpl constructed.", category: .lifecycle)
    }
    
    deinit {
        logger.debug("~NotificationCenterImpl destructed.", category: .lifecycle)
    }
    
    // MARK: - CKNotificationCenter
    
    func notification(name: String) -> AnyPublisher<Notification, Never> {
        let forName = Notification.Name(rawValue: name)
        return observeNotifications(of: notificationCenter, with: forName)
    }
    
    func notification(name: Notification.Name) -> AnyPublisher<Notification, Never> {
        return observeNotifications(of: notificationCenter, with: name)
    }
    
    // MARK: - Private
    
    private let notificationCenter = NotificationCenter.default
    
    private func observeNotifications(of center: NotificationCenter, with name: Notification.Name) -> AnyPublisher<Notification, Never> {
        let publisher = notificationCenter.publisher(
            for: name, object: nil
        )
        return publisher
            .eraseToAnyPublisher()
    }
}
