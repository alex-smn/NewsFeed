//
//  NewsFeedModel.swift
//  NewsFeed
//
//  Created by Alexander Livshits on 16/06/2025.
//

struct NewsFeedSourceModel: Codable {
    var news: [NewsItemSourceModel]
    var totalCount: Int
}

struct NewsFeedModel {
    var news: [NewsItemModel]
    var totalCount: Int
}

