//
//  ImageCommentsPresenterTests.swift
//  EssentialFeed_2023Tests
//
//  Created by Владислав Тодоров on 07.02.2024.
//

import XCTest
import EssentialFeed_2023

class ImageCommentsPresenterTests: XCTestCase {
    func test_title_isLocalized() {
        XCTAssertEqual(ImageCommentsPresenter.title, localized("IMAGE_COMMENTS_VIEW_TITLE"))
        
    }
    
    func test_map_createsViewModels() {
        let now = Date()
        let calendar = Calendar(identifier: .gregorian)
        let locale  = Locale(identifier: "en_US_POSIX")
        
        let comments = [
            ImageComment(
                id: UUID(),
                message: "any message",
                createdAt: now.adding(minutes: -5),
                username: "any username"),
            ImageComment(
                id: UUID(),
                message: "another message",
                createdAt: now.adding(days: -1),
                username: "another username")
        ]
        
        let viewModel = ImageCommentsPresenter.map(
            comments,
            currentDate: now,
            calendar: calendar,
            locale: locale)
        
        XCTAssertEqual(viewModel.comments, [
            ImageCommentViewModel(
                message: "any message",
                date: "5 minutes ago",
                username: "any username"
            ),
            ImageCommentViewModel(
                message: "another message",
                date: "1 day ago",
                username: "another username"
            )
        ])
    }
    
    // MARK: - Helpers
    
    private func localized(_ key: String, file: StaticString = #file, line: UInt = #line) -> String {
        let table = "ImageComments"
        let bundle = Bundle(for: ImageCommentsPresenter.self)
        let value = bundle.localizedString(forKey: key, value: nil, table: table)
        if value == key {
            XCTFail("Missing localized string for key: \(key) in table: \(table)", file: file, line: line)
        }
        return value
    }
}
