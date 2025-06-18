//
//  NewsFeedViewModel.swift
//  NewsFeed
//
//  Created by Alexander Livshits on 16/06/2025.
//

import Combine
import Foundation

enum NewsFeedViewModelState {
    case idle
    case loading
    case error
}

protocol NewsFeedViewModelProtocol {
    var dataPublisher: AnyPublisher<[NewsItemModel], Never> { get }
    var statePublisher: AnyPublisher<NewsFeedViewModelState, Never> { get }
}

class NewsFeedViewModel: NewsFeedViewModelProtocol {
    var dataPublisher: AnyPublisher<[NewsItemModel], Never> {
        $model
            .map { [weak self] model in
                guard let self else { return [] }
                
                return model?.news.map { item in
                    return item.toModel(
                        imagePublisher: self.imageManager
                            .getImagePublisher(from: item.titleImageUrl)
                            .receive(on: DispatchQueue.main)
                            .eraseToAnyPublisher()
                    )
                } ?? []
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    var statePublisher: AnyPublisher<NewsFeedViewModelState, Never> {
        $state
            .combineLatest($model)
            .map { state, model in
                model == nil ? .error : state
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    @Published private var model: NewsFeedSourceModel?
    @Published private var state: NewsFeedViewModelState = .idle
    
    private let repository: NewsFeedRepositoryProtocol
    private let imageManager: ImageManagerProtocol
    
    init(repository: NewsFeedRepositoryProtocol, imageManager: ImageManagerProtocol) {
        self.repository = repository
        self.imageManager = imageManager
        Task { [weak self] in
            guard let self else { return }
            self.model = await self.repository.getData()
            
            self.model?.news.forEach { item in
                Task {
                    await self.imageManager.loadImage(from: item.titleImageUrl)
                }
            }
        }
        
    }
}
