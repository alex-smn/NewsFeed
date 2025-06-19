//
//  NewsItemModel.swift
//  NewsFeed
//
//  Created by Alexander Livshits on 16/06/2025.
//

import Combine
import Foundation
import UIKit

struct NewsItemSourceModel: Codable {
    let id: Int
    let title: String
    let description: String?
    let publishedDate: String?
    let url: String?
    let fullUrl: URL?
    let titleImageUrl: URL?
    let categoryType: String?
}

struct NewsItemModel {
    let id: Int
    let title: String
    let fullUrl: URL?
    var imagePublisher: AnyPublisher<UIImage?, Never>
}

extension NewsItemSourceModel {
    func toModel(imagePublisher: AnyPublisher<UIImage?, Never>) -> NewsItemModel {
        NewsItemModel(id: id, title: title, fullUrl: fullUrl, imagePublisher: imagePublisher)
    }
}
