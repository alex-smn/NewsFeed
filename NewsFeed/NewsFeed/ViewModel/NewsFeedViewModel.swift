//
//  NewsFeedViewModel.swift
//  NewsFeed
//
//  Created by Alexander Livshits on 16/06/2025.
//

import Combine

enum NewsFeedViewModelState {
    case idle
    case loading
}

protocol NewsFeedViewModelProtocol {
    var dataPublisher: AnyPublisher<NewsFeedModel, Never> { get }
    var statePublisher: AnyPublisher<NewsFeedViewModelState, Never> { get }
}

class NewsFeedViewModel {
    
}
