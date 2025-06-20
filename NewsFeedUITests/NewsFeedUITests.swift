//
//  NewsFeedUITests.swift
//  NewsFeedUITests
//
//  Created by Alexander Livshits on 16/06/2025.
//

import XCTest

@testable import NewsFeed

final class NewsFeedUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
    }

    @MainActor
    func testExample() throws {
        let app = XCUIApplication()
        app.launch()

        let collectionView = app.collectionViews["NewsFeedCollectionView"]
        let exists = collectionView.waitForExistence(timeout: 3)
        
        XCTAssertTrue(exists)

        let firstCell = collectionView.cells.element(boundBy: 0)
        XCTAssertTrue(firstCell.exists)
    }

    @MainActor
    func testLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
