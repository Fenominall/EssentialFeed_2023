//
//  ImageCommentCellController.swift
//  EssentialFeed_2023iOS
//
//  Created by Владислав Тодоров on 10.02.2024.
//

import Foundation
import UIKit
import EssentialFeed_2023

public final class ImageCommentCellController: CellController {
    
    private let model: ImageCommentViewModel
    
    public init(model: ImageCommentViewModel) {
        self.model = model
    }
    
    public func view(in tableView: UITableView) -> UITableViewCell {
        let cell: ImageCommentCell = tableView.dequeueReusableCell()
        cell.messageLabel.text = model.message
        cell.usernameLabel.text = model.username
        cell.dateLabel.text = model.date
        return cell
    }
}
