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
    case error(Error)
}

protocol NewsFeedViewModelProtocol {
    var dataPublisher: AnyPublisher<[NewsItemModel], Never> { get }
    var statePublisher: AnyPublisher<NewsFeedViewModelState, Never> { get }
    
    func updateViewVisibility(isVisible: Bool)
    func didShowItem(item: DisplayItemType)
    func didSelectItem(id: Int)
    func tryAgain()
    func reloadData()
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

    @Published private var model: NewsFeedSourceModel
    @Published private var state: NewsFeedViewModelState = .idle
    
    var navigateToArticle: ((URL) -> Void)?
    private let repository: NewsFeedRepositoryProtocol
    private let imageManager: ImageManagerProtocol
    private var subscribers = Set<AnyCancellable>()
    private var dataPage: Int = 1
    private var isLoadingInitiated: Bool = false
    
    init(repository: NewsFeedRepositoryProtocol, imageManager: ImageManagerProtocol) {
        self.repository = repository
        self.imageManager = imageManager
        self.model = NewsFeedSourceModel(news: [], totalCount: 0)
    }
    
    func updateViewVisibility(isVisible: Bool) {
        if isVisible && !isLoadingInitiated {
            loadNextPage()
            isLoadingInitiated = true
        }
    }
    
    func reloadData() {
        dataPage = 1
        model.news = []
        loadNextPage()
    }
    
    func didShowItem(item: DisplayItemType) {
        switch item {
        case .item(let id):
            guard let item = self.model.news.first(where: { $0.id == id }) else { break }
            
            Task { [weak self] in
                guard let self else { return }
                await self.imageManager.loadImage(from: item.titleImageUrl)
            }
            
            if item.id == model.news.last?.id {
                loadNextPage()
            }
        case .loadingSpinner:
            break
        }
    }
    
    func didSelectItem(id: Int) {
        let itemModel = self.model.news.first(where: { $0.id == id })
        if let url = itemModel?.fullUrl {
            navigateToArticle?(url)
        }
    }
    
    func tryAgain() {
        loadData(page: self.dataPage)
    }
    
    private func loadNextPage() {
        if case .loading = state {
            return
        }
        
        loadData(page: self.dataPage)
    }
    
    private func loadData(page: Int) {
        Task { [weak self] in
            guard let self else { return }
            do {
                self.state = .loading
                let newModel = try await self.repository.getData(page: page)
                self.state = .idle
                
                self.model = NewsFeedSourceModel(news: self.model.news + newModel.news, totalCount: newModel.totalCount)
                
                self.dataPage += 1
            } catch {
                self.state = .error(error)
            }
        }
    }
}
