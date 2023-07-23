//
//  FeedImageCell.swift
//  EssentialFeed_2023iOS
//
//  Created by Fenominall on 7/19/23.
//

import UIKit

public final class FeedImageCell: UITableViewCell {
    public let locationContainer = UIView()
    public let locationLabel = UILabel()
    public let descriptionLabel = UILabel()
    public let feedImageContainer = UIView()
    public let feedImageView = UIImageView()
    
    private(set) public lazy var feedImageRetryButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(retryButtontapped), for: .touchUpOutside)
        return button
    }()
    
    var onRetry: (() -> Void)?
    
    @objc private func retryButtontapped() {
        onRetry?()
    }
}
