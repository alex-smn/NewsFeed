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
    
    func updateViewVisibility(isVisible: Bool)
    func didShowItem(item: DisplayItemType)
    func didSelectItem(id: Int)
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
    
    var navigateToArticle: ((URL) -> Void)?
    private let articleLinkSubject = PassthroughSubject<URL, Never>()
    private let repository: NewsFeedRepositoryProtocol
    private let imageManager: ImageManagerProtocol
    private var subscribers = Set<AnyCancellable>()
    private var dataPage: Int = 0
    private var isLoadingInitiated: Bool = false
    
    init(repository: NewsFeedRepositoryProtocol, imageManager: ImageManagerProtocol) {
        self.repository = repository
        self.imageManager = imageManager
        self.model = NewsFeedSourceModel(news: [], totalCount: 0)
    }
    
    func updateViewVisibility(isVisible: Bool) {
        if isVisible && !isLoadingInitiated {
            loadData(page: 0)
            isLoadingInitiated = true
        }
    }
    
    func didShowItem(item: DisplayItemType) {
        if state != .loading {
            if item == DisplayItemType.loadingSpinner {
                self.dataPage += 1
                self.loadData(page: self.dataPage)
            }
        }
    }
    
    func didSelectItem(id: Int) {
        let itemModel = self.model.news.first(where: { $0.id == id })
        if let url = itemModel?.fullUrl {
            navigateToArticle?(url)
        }
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
