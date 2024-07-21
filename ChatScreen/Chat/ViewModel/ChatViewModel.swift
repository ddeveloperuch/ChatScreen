//
//  ChatViewModel.swift
//  ChatScreen
//
//  Created by Developer on 20/07/2024.
//  Copyright © 2024 Developer Software Foundation. All rights reserved.
//

import Combine
import Foundation
import Swinject
import UIKit

enum ChatMessage: Equatable {
    
    case stringable(content: String)
    case imageable(content: [UIImage])
}

enum ChatCellSpecification: Equatable {
    
    case textMessage(text: String)
    case singleImageMessage(image: UIImage)
    case imagesMessage(images: [UIImage])
}

struct TextEditorInfo {
    
    struct Placeholder {
        let text: String
        let color: UIColor
    }
    
    let textColor: UIColor
    let placeholder: Placeholder
}

protocol ChatViewModel {
    
    var arrangeSections: AnyPublisher<Void, Never> { get }
    var bottomIndexPath: IndexPath? { get }
    var textEditorInfo: TextEditorInfo { get }
    
    func numberOfItemsInSection(section: Int) -> Int
    func cellSpecificationFor(indexPath: IndexPath) -> ChatCellSpecification
    func numberOfSections() -> Int
    
    func sendMessage(_ text: String)
    func sendMoreMessages()
    func sendImages(_ images: [UIImage])
    func deleteMessage(at indexPath: IndexPath)
}

class ChatViewModelFactory {
    public static func register(with container: Container) {
        container.register(ChatViewModel.self) { _ in
            return ChatViewModelImpl()
        }.inObjectScope(.transient)
    }
}

fileprivate final class ChatViewModelImpl: ChatViewModel {
    
    // MARK: - Lifecycle

    init() {
        logger.debug("ChatViewModelImpl constructed.", category: .lifecycle)
    }
    
    deinit {
        logger.debug("~ChatViewModelImpl destructed.", category: .lifecycle)
    }
    
    // MARK: - ChatViewModel
    
    var arrangeSections: AnyPublisher<Void, Never> {
        return arrangeSectionsPublisher.eraseToAnyPublisher()
    }
    
    var bottomIndexPath: IndexPath? {
        return messagesQueue.sync {
            guard !internalMessages.isEmpty else {
                return nil
            }
            let lastMessageIndex = internalMessages.startIndex
            return IndexPath(row: lastMessageIndex, section: Helpers.Section.mainChat.rawValue)
        }
    }
    
    lazy var textEditorInfo: TextEditorInfo = {
        return TextEditorInfo(
            textColor: Helpers.TextEditor.textColor,
            placeholder: TextEditorInfo.Placeholder(
                text: Helpers.TextEditor.placeholder,
                color: Helpers.TextEditor.placeholderTextColor
            )
        )
    }()
    
    func numberOfItemsInSection(section: Int) -> Int {
        return messagesQueue.sync {
            self.internalMessages.count
        }
    }
    
    func cellSpecificationFor(indexPath: IndexPath) -> ChatCellSpecification {
        return messagesQueue.sync {
            let reversedIndex = normalizedMessageIndex(for: indexPath)
            guard let message = internalMessages[safe: reversedIndex] else {
                assertionFailure("Unexpected section=\(indexPath.section); row=\(indexPath.row).")
                return ChatCellSpecification.textMessage(text: "")
            }
            let cellSpecification: ChatCellSpecification
            switch message {
                
            case let .stringable(content):
                cellSpecification = .textMessage(text: content)
                
            case let .imageable(content):
                if content.count == 1 {
                    cellSpecification = .singleImageMessage(image: content.first!)
                } else {
                    cellSpecification = .imagesMessage(images: content)
                }
            }
            return cellSpecification
        }
    }
    
    func numberOfSections() -> Int {
        return Helpers.Section.allCases.count
    }
    
    func sendMessage(_ text: String) {
        let message: ChatMessage = .stringable(
            content: text
        )
        addMessage(message)
    }
    
    func sendMoreMessages() {
        let moreMessages = Helpers.generateRandomMessages()
        addMoreMessages(moreMessages)
    }
    
    func sendImages(_ images: [UIImage]) {
        let message: ChatMessage = .imageable(
            content: images
        )
        addMessage(message)
    }
    
    func deleteMessage(at indexPath: IndexPath) {
        messagesQueue.async { [weak self] in
            guard let this = self else {
                return
            }
            let reversedIndex = this.normalizedMessageIndex(for: indexPath)
            this.internalMessages.remove(at: reversedIndex)
            this.arrangeSectionsPublisher.send(())
        }
    }
    
    // MARK: - Private
    
    private enum Helpers {
        
        enum Section: Int, CaseIterable {
            
            case mainChat
        }
        
        enum TextEditor {
            
            static let placeholder = "Message"

            static let textColor = UIColor.darkText
            static let placeholderTextColor = UIColor.systemGray4
        }
        
        static func generateRandomMessages() -> [ChatMessage] {
            var randomMessages = [ChatMessage]()
            let numberOfMessages = Int.random(in: 3...5)
            for _ in 0..<numberOfMessages {
                let messageLength = Int.random(in: 50...300)
                let randomMessage = String((0..<messageLength).map { _ in "abcdefghijklmnopqrstuvwxyz1234567890".randomElement()! })
                randomMessages.append(
                    .stringable(content: randomMessage)
                )
            }
            return randomMessages
        }
    }
    
    private let messagesQueue = DispatchQueue(label: "com.testAssignment.ChatScreen.messagesQueue")
    private var internalMessages = [ChatMessage]()
    
    private let arrangeSectionsPublisher = PassthroughSubject<Void, Never>()
    
    private func addMessage(_ message: ChatMessage) {
        messagesQueue.async { [weak self] in
            self?.internalMessages.append(message)
            self?.arrangeSectionsPublisher.send(())
        }
    }
    
    private func addMoreMessages(_ newMessages: [ChatMessage]) {
        messagesQueue.async { [weak self] in
            guard let this = self else {
                return
            }
            this.internalMessages.insert(
                contentsOf: newMessages, at: this.internalMessages.endIndex)
            this.arrangeSectionsPublisher.send(())
        }
    }
    
    // MARK: -
    
    // Note: Provides a reverse index.
    func normalizedMessageIndex(for indexPath: IndexPath) -> Int {
        return internalMessages.count - 1 - indexPath.row
    }
}
