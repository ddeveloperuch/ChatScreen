//
//  ChatViewController.swift
//  ChatScreen
//
//  Created by Developer on 20/07/2024.
//  Copyright © 2024 Developer Software Foundation. All rights reserved.
//

import Combine
import UIKit
import Swinject
import PhotosUI

class ChatViewController: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var tableView: CKTableView!
    @IBOutlet weak var textEditorView: CKTextView!
    @IBOutlet weak var sendMessageButton: UIButton!
    
    // MARK: - IBActions
    
    @IBAction func sendMessageBtnPressed(_ sender: Any) {
        handleSendMessageBtnPressed()
    }
    
    @IBAction func sendMoreMessagesBtnPressed(_ sender: Any) {
        handleSendMoreMessagesBtnPressed()
    }
    
    @IBAction func sendImageBtnPressed(_ sender: Any) {
        handleSendImageBtnPressed()
    }
    
    // MARK: - Lifecycle
    
    required init?(coder: NSCoder) {
        
        let resolver = Container.default.resolver
        self.viewModel = resolver.resolve(ChatViewModel.self)!
        self.keyboardManager = resolver.resolve(CKKeyboardManager.self)!
        
        super.init(coder: coder)
        logger.debug("ChatViewController constructed.", category: .lifecycle)
    }
    
    deinit {
        logger.debug("~ChatViewController.", category: .lifecycle)
    }
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTableView()
        configureTextContainer()
        setupViewModelObserver()
        setupKeyboardObserver()
    }
    
    // MARK: - Private
    
    private var subscriptions = Set<AnyCancellable>()
    
    private let viewModel: ChatViewModel
    private let keyboardManager: CKKeyboardManager
    
    // MARK: -
    
    private func configureTableView() {
        tableView.transform = CGAffineTransform(rotationAngle: .pi)
    }
    
    private func configureTextContainer() {
        
        let textEditorInfo = viewModel.textEditorInfo
        textEditorView.text = textEditorInfo.placeholder.text
        textEditorView.textColor = textEditorInfo.placeholder.color
        
        textEditorView.selectedTextRange = textEditorView.textRange(
            from: textEditorView.beginningOfDocument,
            to: textEditorView.beginningOfDocument
        )
    }
    
    private func setupViewModelObserver() {
        viewModel.arrangeSections
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                self?.handleArrangeSections()
            })
            .store(in: &subscriptions)
    }
    
    private func handleArrangeSections() {
        tableView.reloadDataWithCompletion { [weak self] in
            self?.scrollToBottom()
        }
    }
    
    private func scrollToBottom(){
        DispatchQueue.main.async { [weak self] in
            guard let this = self,
                  let bottomIndexPath = this.viewModel.bottomIndexPath,
                  this.tableView.indexPathExists(indexPath: bottomIndexPath) else {
                return
            }
            this.tableView.scrollToRow(
                at: bottomIndexPath,
                at: .bottom,
                animated: true
            )
        }
    }
    
    // MARK: - Keyboard
    
    private func setupKeyboardObserver() {
     
        let tapGestureRecognizer = UITapGestureRecognizer(
            target: self, action: #selector(handleTap)
        )
        tapGestureRecognizer.delegate = self
        view.addGestureRecognizer(tapGestureRecognizer)
        
        keyboardManager.event
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] keyboardEvent in
                self?.handleKeyboardEvent(keyboardEvent)
            })
            .store(in: &subscriptions)
    }
    
    private func handleKeyboardEvent(_ keyboardEvent: CKKeyboardEvent) {
        
        switch keyboardEvent {
            
        case let .willShow(keyboardFrame):
            guard view.frame.origin.y == .zero else {
                return
            }
            let keyboardHeight = keyboardFrame.height
            view.frame.origin.y = -keyboardHeight
            
        case .willHide:
            guard view.frame.origin.y != .zero else {
                return
            }
            view.frame.origin.y = .zero
        }
    }
    
    @objc private func handleTap(_ sender: Any) {
        dismissKeyboard()
    }
    
    private func dismissKeyboard() {
        textEditorView.resignFirstResponder()
    }
    
    // MARK: - Message Send
    
    private func handleSendMessageBtnPressed() {
        defer {
            dismissKeyboard()
        }
        
        let textEditorInfo = viewModel.textEditorInfo
        guard !textEditorView.text.isEmpty,
              textEditorView.text != textEditorInfo.placeholder.text else {
            return
        }
        
        viewModel.sendMessage(textEditorView.text)
        
        textEditorView.text = textEditorInfo.placeholder.text
        textEditorView.textColor = textEditorInfo.placeholder.color

        textViewDidChangeSelection(textEditorView)
    }
    
    private func handleSendMoreMessagesBtnPressed() {
        viewModel.sendMoreMessages()
    }
    
    private func handleSendImageBtnPressed() {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 0
        configuration.filter = .images
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
}

extension ChatViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfItemsInSection(section: section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellSpecification = viewModel.cellSpecificationFor(indexPath: indexPath)
        let deletableCell: DeletableCell
        switch cellSpecification {
            
        case let .textMessage(text):
            let cell = tableView.dequeueReusableCell(
                withIdentifier: StringableChatTableViewCell.reuseIdentifier,
                for: indexPath
            ) as! StringableChatTableViewCell
            cell.configure(with: text)
            deletableCell = cell
            
        case let .singleImageMessage(image):
            let cell = tableView.dequeueReusableCell(
                withIdentifier: SingleImageableChatTableViewCell.reuseIdentifier,
                for: indexPath
            ) as! SingleImageableChatTableViewCell
            cell.configure(with: image)
            deletableCell = cell
            
        case let .imagesMessage(images):
            let cell = tableView.dequeueReusableCell(
                withIdentifier: ImageableChatTableViewCell.reuseIdentifier,
                for: indexPath
            ) as! ImageableChatTableViewCell
            cell.configure(with: images)
            deletableCell = cell
        }
        deletableCell.deleteAction.sink(receiveValue: { [weak self, indexPath] _ in
            self?.viewModel.deleteMessage(at: indexPath)
        })
        .store(in: &deletableCell.subscriptions)
        
        deletableCell.transform = CGAffineTransform(rotationAngle: .pi)
        return deletableCell
    }
}

extension ChatViewController: PHPickerViewControllerDelegate {
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        
        picker.dismiss(animated: true, completion: nil)
        
        var images = [UIImage]()
        let group = DispatchGroup()
        
        for result in results {
            group.enter()
            if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                result.itemProvider.loadObject(ofClass: UIImage.self) { (object, error) in
                    if let image = object as? UIImage {
                        images.append(image)
                    }
                    group.leave()
                }
            } else {
                group.leave()
            }
        }
        group.notify(queue: .main) { [weak self] in
            guard !images.isEmpty else {
                return
            }
            self?.viewModel.sendImages(images)
        }
    }
}

extension ChatViewController: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {

        let textEditorInfo = viewModel.textEditorInfo
        
        // If updated text view will be empty, add the placeholder
        // and set the cursor to the beginning of the text view
        if text.isEmpty {

            // Combine the textView text and the replacement text to
            // create the updated text string.
            let currentText: String = textView.text
            let updatedText = (currentText as NSString).replacingCharacters(in: range, with: text)
            
            if updatedText.isEmpty {
                textView.text = textEditorInfo.placeholder.text
                textView.textColor = textEditorInfo.placeholder.color
                textView.selectedRange = NSRange(location: .zero, length: .zero)
            }
        }
        // Else if the text view's placeholder is showing and the
        // length of the replacement string is greater than 0, set
        // the text color to `textColor` then set its text to the replacement string.
         else {
             if textView.text == textEditorInfo.placeholder.text {
                 textView.text = ""
             }
             textView.textColor = textEditorInfo.textColor
        }
        return true
    }

    func textViewDidChange(_ textView: UITextView) {
        
        let textEditorInfo = viewModel.textEditorInfo
        if textView.text.isEmpty {
            textView.text = textEditorInfo.placeholder.text
            textView.textColor = textEditorInfo.placeholder.color
        } else {
            textView.textColor = textEditorInfo.textColor
        }
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        // Prevents the user from changing the position of the cursor while the placeholder's visible.
        // `textViewDidChangeSelection` is called before the view loads.
        let textEditorInfo = viewModel.textEditorInfo
        guard view.window != nil,
              textView.textColor == textEditorInfo.placeholder.color else {
            return
        }
        textView.selectedRange = NSRange(location: .zero, length: .zero)
    }
}
