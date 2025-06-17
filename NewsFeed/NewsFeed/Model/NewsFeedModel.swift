//
//  NewsFeedModel.swift
//  NewsFeed
//
//  Created by Alexander Livshits on 16/06/2025.
//

struct NewsFeedModel: Codable {
    let news: [NewsItemModel]
    let totalCount: Int
}
