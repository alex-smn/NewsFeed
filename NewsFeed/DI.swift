//
//  DI.swift
//  NewsFeed
//
//  Created by Alexander Livshits on 18/06/2025.
//

import Foundation
import UIKit

class DI {
    static let localDataStorage = LocalDataStorage()
    static let imageManager = ImageManager(dataStorage: localDataStorage)
    
    static var mockNewsFeedViewController: UIViewController {
        let mockNewsFeedRepository = MockNewsFeedRepository()
        let newsFeedViewModel = NewsFeedViewModel(repository: mockNewsFeedRepository, imageManager: imageManager)
        return NewsFeedViewController(viewModel: newsFeedViewModel)
    }
}
