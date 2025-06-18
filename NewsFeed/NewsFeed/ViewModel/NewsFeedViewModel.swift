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
    var hasMoreDataPublisher: AnyPublisher<Bool, Never> { get }
}

class NewsFeedViewModel: NewsFeedViewModelProtocol {
    var dataPublisher: AnyPublisher<[NewsItemModel], Never> {
        $model
            .map { [weak self] model in
                guard let self else { return [] }
                
                return model.news.map { item in
                    return item.toModel(
                        imagePublisher: self.imageManager
                            .getImagePublisher(from: item.titleImageUrl)
                            .receive(on: DispatchQueue.main)
                            .eraseToAnyPublisher()
                    )
                }
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    var statePublisher: AnyPublisher<NewsFeedViewModelState, Never> {
        $state
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    var hasMoreDataPublisher: AnyPublisher<Bool, Never> {
        $model
            .map { model in
                model.news.count < model.totalCount
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    @Published private var model: NewsFeedSourceModel
    @Published private var state: NewsFeedViewModelState = .idle
    
    private let repository: NewsFeedRepositoryProtocol
    private let imageManager: ImageManagerProtocol
    private var subscribers = Set<AnyCancellable>()
    private var dataPage: Int = 0
    
    weak var viewController: NewsFeedViewProtocol? {
        didSet {
            subscribeToPublishers()
        }
    }
    
    init(repository: NewsFeedRepositoryProtocol, imageManager: ImageManagerProtocol) {
        self.repository = repository
        self.imageManager = imageManager
        self.model = NewsFeedSourceModel(news: [], totalCount: 0)
    }
    
    private func subscribeToPublishers() {
        viewController?.visibilityPublisher.first(where: { $0 }).sink { [weak self] _ in
            self?.loadData(page: 0)
        }.store(in: &subscribers)
        
        viewController?.visibleItemsPublisher.sink(receiveValue: { [weak self] items in
            guard
                let self,
                self.state != .loading
            else {
                return
            }
            if items.contains(where: { $0 == DisplayItemType.loadingSpinner }) {
                self.dataPage += 1
                self.loadData(page: self.dataPage)
            }
        }).store(in: &subscribers)
    }
    
    private func loadData(page: Int) {
        Task { [weak self] in
            guard let self else { return }
            
            self.state = .loading
            if let newModel = await self.repository.getData(page: page) {
                self.state = .idle
                
                self.model.news += newModel.news
                self.model.totalCount = newModel.totalCount
                
                self.model.news.forEach { item in
                    Task {
                        await self.imageManager.loadImage(from: item.titleImageUrl)
                    }
                }

            } else {
                self.state = .error
            }
        }
    }
}
