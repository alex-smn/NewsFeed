//
//  NewsFeedTests.swift
//  NewsFeedTests
//
//  Created by Alexander Livshits on 16/06/2025.
//

import Combine
import XCTest

class NewsFeedViewModelTests: XCTestCase {
    var newsFeedViewModel: NewsFeedViewModel!
    var repository: MockNewsFeedRepository!
    var imageManager: MockImageManager!
    
    override func setUp() {
        repository = MockNewsFeedRepository()
        imageManager = MockImageManager()
        newsFeedViewModel = NewsFeedViewModel(repository: repository, imageManager: imageManager)
    }
    
    override func tearDown() {
        repository = nil
        imageManager = nil
        newsFeedViewModel = nil
    }

    func testUpdateViewVisibility() {
        newsFeedViewModel.updateViewVisibility(isVisible: true)
        sleep(1)
        XCTAssert(repository.requestedPagesList == [1])
    }
    
    func testUpdateViewVisibilityFalse() {
        newsFeedViewModel.updateViewVisibility(isVisible: false)
        sleep(1)
        XCTAssert(repository.requestedPagesList == [])
    }
    
    func testDidShowItemImageLoading() {
        newsFeedViewModel.updateViewVisibility(isVisible: true)
        sleep(1)
        let item = repository.model.news[0]
        newsFeedViewModel.didShowItem(item: .item(id: item.id))
        sleep(1)
        XCTAssert(imageManager.loadImageList == [item.titleImageUrl])
    }
    
    func testDidShowItemImageLoadingNoItem() {
        newsFeedViewModel.updateViewVisibility(isVisible: true)
        sleep(1)
        newsFeedViewModel.didShowItem(item: .item(id: 42))
        sleep(1)
        XCTAssert(imageManager.loadImageList.isEmpty)
    }
    
    func testDidShowItemShouldNotLoadMore() {
        newsFeedViewModel.updateViewVisibility(isVisible: true)
        sleep(1)
        let item = repository.model.news[0]
        newsFeedViewModel.didShowItem(item: .item(id: item.id))
        sleep(1)
        XCTAssert(repository.requestedPagesList == [1])
    }
    
    func testDidShowItemShouldLoadMore() {
        newsFeedViewModel.updateViewVisibility(isVisible: true)
        sleep(1)
        let item = repository.model.news.last!
        newsFeedViewModel.didShowItem(item: .item(id: item.id))
        sleep(1)
        XCTAssert(repository.requestedPagesList == [1, 2])
    }
    
    func testDidSelectItem() {
        let exp = expectation(description: "wait for navigation")
        newsFeedViewModel.updateViewVisibility(isVisible: true)
        sleep(1)
        let item = repository.model.news[0]
        newsFeedViewModel.navigateToArticle = { url in
            XCTAssert(url == item.fullUrl)
            exp.fulfill()
        }
        
        newsFeedViewModel.didSelectItem(id: item.id)
        wait(for: [exp], timeout: 1)
    }
    
    func testDidSelectNoItem() {
        let exp = expectation(description: "wait for navigation")
        exp.isInverted = true
        newsFeedViewModel.updateViewVisibility(isVisible: true)
        sleep(1)
        newsFeedViewModel.navigateToArticle = { url in
            exp.fulfill()
        }
        
        newsFeedViewModel.didSelectItem(id: 42)
        wait(for: [exp], timeout: 1)
    }
    
    func testTryAgain() {
        repository.isCorrect = false
        newsFeedViewModel.updateViewVisibility(isVisible: true)
        sleep(1)
        XCTAssert(repository.requestedPagesList == [1])
        newsFeedViewModel.tryAgain()
        sleep(1)
        XCTAssert(repository.requestedPagesList == [1, 1])
    }

}
