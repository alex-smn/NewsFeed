//
//  NewsItemModel.swift
//  NewsFeed
//
//  Created by Alexander Livshits on 16/06/2025.
//

import Foundation

struct NewsItemModel: Codable {
    let id: Int
    let title: String
    let description: String
    let publishedDate: String
    let url: String
    let fullUrl: URL
    let titleImageUrl: URL
    let categoryType: String
}
