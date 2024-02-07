//
//  ImageCommentsPresenter.swift
//  EssentialFeed_2023
//
//  Created by Владислав Тодоров on 07.02.2024.
//

import Foundation

public final class ImageCommentsPresenter {
    public static var title: String {
        return NSLocalizedString("IMAGE_COMMENTS_VIEW_TITLE",
                                 tableName: "ImageComments",
                                 bundle: Bundle(for: ImageCommentsPresenter.self),
                                 comment: "Title for the image comments view")
    }
}
