//
//  DeletableCell.swift
//  ChatScreen
//
//  Created by Developer on 20/07/2024.
//  Copyright © 2024 Developer Software Foundation. All rights reserved.
//

import Combine
import UIKit

class DeletableCell: UITableViewCell, UIContextMenuInteractionDelegate {
    
    var subscriptions = Set<AnyCancellable>()
    
    var deleteAction: AnyPublisher<Void, Never> {
        return deleteActionPublisher.eraseToAnyPublisher()
    }
    
    // MARK: - UITableViewCell
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        configure()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        configure()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        subscriptions.removeAll()
    }
    
    // MARK: - UIContextMenuInteractionDelegate
    
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            let deleteAction = UIAction(
                title: "Delete", attributes: .destructive
            ) { [weak self] _ in
                self?.deleteActionPublisher.send(())
            }
            return UIMenu(title: "", children: [deleteAction])
        }
    }
    
    // MARK: - Private
    
    private let deleteActionPublisher = PassthroughSubject<Void, Never>()
    
    private func configure() {
        let interaction = UIContextMenuInteraction(delegate: self)
        contentView.addInteraction(interaction)
    }
}
