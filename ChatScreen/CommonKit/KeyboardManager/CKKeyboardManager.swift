//
//  KeyboardManager.swift
//  ChatScreen
//
//  Created by Developer on 20/07/2024.
//  Copyright © 2024 Developer Software Foundation. All rights reserved.
//

import UIKit
import Combine
import Swinject

enum CKKeyboardEvent {
    
    case willShow(keyboardFrame: CGRect)
    case willHide
}

protocol CKKeyboardManager {
    
    var event: AnyPublisher<CKKeyboardEvent, Never> { get }
}

class CKKeyboardManagerFactory {
    
    static func register(with container: Container) {
        
        let threadSafeResolver = container.synchronize()
        
        container.register(CKKeyboardManager.self) { _ in
            
            return KeyboardManagerImpl(with: threadSafeResolver)
            
        }.inObjectScope(.transient)
    }
}

private class KeyboardManagerImpl: CKKeyboardManager {
    
    // MARK: - Lifecycle

    init(with resolver: Resolver) {
    
        self.notificationCenter = resolver.resolve(CKNotificationCenter.self)!
        
        // UIKeyboardWillShowNotification
        self.notificationCenter.notification(name: UIResponder.keyboardWillShowNotification.rawValue)
            .sink { [weak self] notification in
                if let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                    self?.keyboardSizeSubject.send(
                        .willShow(keyboardFrame: keyboardFrame)
                    )
                }
            }
            .store(in: &subscriptions)
        
        // UIKeyboardWillHideNotification
        self.notificationCenter.notification(name: UIResponder.keyboardWillHideNotification.rawValue)
            .sink { [weak self] notification in
                self?.keyboardSizeSubject.send(
                    .willHide
                )
            }
            .store(in: &subscriptions)
        
        logger.debug("KeyboardManagerImpl constructed.", category: .lifecycle)
    }
    
    deinit {
        logger.debug("~KeyboardManagerImpl.", category: .lifecycle)
    }
    
    // MARK: - CKKeyboardManager
    
    var event: AnyPublisher<CKKeyboardEvent, Never> {
        return keyboardSizeSubject
            .eraseToAnyPublisher()
    }
    
    // MARK: - Private
    
    private let notificationCenter: CKNotificationCenter

    private var subscriptions = Set<AnyCancellable>()
    private let keyboardSizeSubject = PassthroughSubject<CKKeyboardEvent, Never>()
}
