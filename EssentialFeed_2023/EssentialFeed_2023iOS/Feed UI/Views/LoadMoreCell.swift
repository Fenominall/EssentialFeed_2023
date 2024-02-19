//
//  LoadMoreCell.swift
//  EssentialFeed_2023iOS
//
//  Created by Владислав Тодоров on 19.02.2024.
//

import UIKit

public final class LoadMoreCell: UITableViewCell {
    private lazy var spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .medium)
        
        contentView.addSubview(spinner)
        
        spinner.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            spinner.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            spinner.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            spinner.heightAnchor.constraint(lessThanOrEqualToConstant: 40)
        ])
        return spinner
    }()
    
    public var isLoading: Bool {
        get { spinner.isAnimating }
        set {
            if newValue {
                spinner.startAnimating()
            } else {
                spinner.stopAnimating()
            }
        }
    }
}
