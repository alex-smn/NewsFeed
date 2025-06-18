//
//  WebNewsFeedRepository.swift
//  NewsFeed
//
//  Created by Alexander Livshits on 17/06/2025.
//

import Foundation

class WebNewsFeedRepository: NewsFeedRepositoryProtocol {
    private let newsPerPage = 15
    
    func getData(page: Int) async -> NewsFeedSourceModel? {
        let apiURL = Constants.apiBaseURL + "news/\(page)/\(newsPerPage)"

        do {
            let (data, _) = try await URLSession.shared.data(from: URL(string: apiURL)!)
            let newsFeedDataModel = try JSONDecoder().decode(NewsFeedSourceModel.self, from: data)
            return newsFeedDataModel
        } catch {
            print("Failed to load news:", error.localizedDescription) // TODO: handle error
            return nil
        }
    }
}
