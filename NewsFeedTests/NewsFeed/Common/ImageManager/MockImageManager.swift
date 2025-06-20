//
//  MockImageManager.swift
//  NewsFeed
//
//  Created by Alexander Livshits on 20/06/2025.
//

import Combine
import Foundation
import UIKit

class MockImageManager: ImageManagerProtocol {
    var imagePublisher: AnyPublisher<UIImage?, Never> = Just<UIImage?>(UIImage(systemName: "photo")).eraseToAnyPublisher()
    var loadImageList = [URL?]()
    
    func getImagePublisher(from url: URL?) -> AnyPublisher<UIImage?, Never> {
        return imagePublisher
    }
    
    func loadImage(from url: URL?) async {
        loadImageList.append(url)
    }
}
