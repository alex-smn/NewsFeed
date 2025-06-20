//
//  NewsFeedRepositoryProtocol.swift
//  NewsFeed
//
//  Created by Alexander Livshits on 20/06/2025.
//

import Foundation

protocol NewsFeedRepositoryProtocol {
    func getData(page: Int) async throws -> NewsFeedSourceModel
}
