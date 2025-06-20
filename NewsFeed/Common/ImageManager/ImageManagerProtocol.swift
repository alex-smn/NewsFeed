//
//  ImageManagerProtocol.swift
//  NewsFeed
//
//  Created by Alexander Livshits on 20/06/2025.
//

import Combine
import Foundation
import UIKit

protocol ImageManagerProtocol {
    func getImagePublisher(from url: URL?) -> AnyPublisher<UIImage?, Never>
    func loadImage(from url: URL?) async
}
