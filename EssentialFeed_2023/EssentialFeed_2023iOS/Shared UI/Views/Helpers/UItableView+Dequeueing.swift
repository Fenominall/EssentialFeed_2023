//
//  UItableView+Dequeueing.swift
//  EssentialFeed_2023iOS
//
//  Created by Fenominall on 11/20/23.
//

import UIKit

extension UITableView {
    func dequeueReusableCell<T: UITableViewCell>() -> T {
        let identifier = String(describing: T.self)
        return dequeueReusableCell(withIdentifier: identifier) as! T
    }
}
