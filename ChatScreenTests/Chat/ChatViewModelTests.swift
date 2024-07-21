//
//  ChatViewModelTests.swift
//  ChatScreenTests
//
//  Created by Developer on 20/07/2024.
//  Copyright © 2024 Developer Software Foundation. All rights reserved.
//

import Swinject
import XCTest

final class ChatViewModelTests: XCTestCase {

    // MARK: -
    
    private final class Mock {
        
        let container = Container()
        
        func dispose() {
            container.removeAll()
        }
    }
    private var mock: Mock! = Mock()
    
    // MARK: -
    
    override func setUp() {
        super.setUp()
        
        continueAfterFailure = false
        
        ChatViewModelFactory.register(with: mock.container)
    }
    
    override func tearDown() {
        
        mock.dispose()
        mock = nil
        
        super.tearDown()
    }
    
    private func resolveChatViewModel() -> ChatViewModel {
        
        let chatViewModel: ChatViewModel! = mock.container.resolve(ChatViewModel.self)
        XCTAssertNotNil(chatViewModel)
        
        return chatViewModel
    }
    
    // MARK: - Tests
    
    func testInitial() {
        
        var _ = resolveChatViewModel()
    }
    
    func testNumberOfItemsInSection() {
        let viewModel = resolveChatViewModel()
        
        viewModel.sendMessage("Test message")
        XCTAssertEqual(viewModel.numberOfItemsInSection(section: 0), 1)
    }
    
    func testCellSpecificationForTextMessage() {
        let viewModel = resolveChatViewModel()
        
        viewModel.sendMessage("Test message")
        let indexPath = IndexPath(row: 0, section: 0)
        let cellSpecification = viewModel.cellSpecificationFor(indexPath: indexPath)
        XCTAssertEqual(cellSpecification, .textMessage(text: "Test message"))
    }

    func testCellSpecificationForSingleImageMessage() {
        let viewModel = resolveChatViewModel()
        
        let testImage = UIImage()
        viewModel.sendImages([testImage])
        let indexPath = IndexPath(row: 0, section: 0)
        let cellSpecification = viewModel.cellSpecificationFor(indexPath: indexPath)
        XCTAssertEqual(cellSpecification, .singleImageMessage(image: testImage))
    }

    func testCellSpecificationForMultipleImagesMessage() {
        let viewModel = resolveChatViewModel()
        
        let testImages = [UIImage(), UIImage()]
        viewModel.sendImages(testImages)
        let indexPath = IndexPath(row: 0, section: 0)
        let cellSpecification = viewModel.cellSpecificationFor(indexPath: indexPath)
        XCTAssertEqual(cellSpecification, .imagesMessage(images: testImages))
    }
    
    func testAddingMultipleMessages() {
        let chatViewModel = resolveChatViewModel()
        
        let messages = ["First message", "Second message", "Third message"]
        messages.forEach { chatViewModel.sendMessage($0) }
        
        XCTAssertEqual(chatViewModel.numberOfItemsInSection(section: 0), messages.count)
        
        for (index, message) in messages.reversed().enumerated() {
            let indexPath = IndexPath(row: index, section: 0)
            let cellSpecification = chatViewModel.cellSpecificationFor(indexPath: indexPath)
            XCTAssertEqual(cellSpecification, .textMessage(text: message))
        }
    }

    func testDeletingMessage() {
        let chatViewModel = resolveChatViewModel()
        
        let messages = ["First message", "Second message", "Third message"]
        messages.forEach { chatViewModel.sendMessage($0) }
        
        let indexPathToDelete = IndexPath(row: 1, section: 0)
        chatViewModel.deleteMessage(at: indexPathToDelete)
        
        XCTAssertEqual(chatViewModel.numberOfItemsInSection(section: 0), messages.count - 1)
        
        let remainingMessages = ["First message", "Third message"]
        for (index, message) in remainingMessages.reversed().enumerated() {
            let indexPath = IndexPath(row: index, section: 0)
            let cellSpecification = chatViewModel.cellSpecificationFor(indexPath: indexPath)
            XCTAssertEqual(cellSpecification, .textMessage(text: message))
        }
    }

    func testCombinationOfOperations() {
        let chatViewModel = resolveChatViewModel()
        
        let messages = ["Message 1", "Message 2", "Message 3"]
        messages.forEach { chatViewModel.sendMessage($0) }
        
        XCTAssertEqual(chatViewModel.numberOfItemsInSection(section: 0), messages.count)
        
        chatViewModel.deleteMessage(at: IndexPath(row: 0, section: 0))
        XCTAssertEqual(chatViewModel.numberOfItemsInSection(section: 0), messages.count - 1)
        
        let remainingMessages = ["Message 1", "Message 2"]
        for (index, message) in remainingMessages.reversed().enumerated() {
            let indexPath = IndexPath(row: index, section: 0)
            let cellSpecification = chatViewModel.cellSpecificationFor(indexPath: indexPath)
            XCTAssertEqual(cellSpecification, .textMessage(text: message))
        }
        
        chatViewModel.sendMoreMessages()
        XCTAssertGreaterThan(chatViewModel.numberOfItemsInSection(section: 0), remainingMessages.count)
    }
}
