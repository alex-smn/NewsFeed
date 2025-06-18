//
//  WebNewsFeedRepository.swift
//  NewsFeed
//
//  Created by Alexander Livshits on 17/06/2025.
//

import Foundation

class WebNewsFeedRepository: NewsFeedRepositoryProtocol {
    let apiURL = Constants.apiBaseURL + "news/1/15"
    
    func getData() async -> NewsFeedSourceModel? {
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
