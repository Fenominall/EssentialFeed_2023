//
//  UITableView+HeaderSizing.swift
//  EssentialFeed_2023iOS
//
//  Created by Владислав Тодоров on 14.01.2024.
//

import UIKit

extension UITableView {
    func sizeTableHeaderFit() {
        guard let header = tableHeaderView else { return }
        
        let size = header.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        
        let needsFrameUpdate = header.frame.height != size.height
        if needsFrameUpdate {
            header.frame.size.height = size.height
            tableHeaderView = header
        }
    }
}
