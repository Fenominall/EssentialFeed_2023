//
//  SceneDelegateTests.swift
//  EssentialAppTests
//
//  Created by Владислав Тодоров on 12.01.2024.
//

import XCTest
@testable import EssentialApp
import EssentialFeed_2023iOS

class SceneDelegateTests: XCTestCase {
    
    func test_configureWindow_setsWindowAsKeyAndVisible() {
        let window = UIWindow()
        let sut = SceneDelegate()
        sut.window = window
        
        sut.configureWindow()
 
        XCTAssertTrue(((sut.window?.isKeyWindow) != nil), "Expcted window to be the key window")
        XCTAssertFalse(window.isHidden, "Expected window to be visible")
    }
    
    
    func test_configureWindow_configuresRootViewController() {
        let sut = SceneDelegate()
        sut.window = UIWindow()
        
        sut.configureWindow()
        
        let root = sut.window?.rootViewController
        let rootNavigation = root as? UINavigationController
        let topController = rootNavigation?.topViewController
        
        XCTAssertNotNil(rootNavigation, "Expected a navigation controller as root, got  \(String(describing: root)) instead")
        XCTAssertTrue(topController is ListViewController, "Expected a feed controlle as top view controller, got \(String(describing: topController)) instead")
    }
}
