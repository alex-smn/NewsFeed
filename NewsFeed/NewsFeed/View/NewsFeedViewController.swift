//
//  NewsFeedViewController.swift
//  NewsFeed
//
//  Created by Alexander Livshits on 16/06/2025.
//

import Combine
import UIKit

protocol NewsFeedViewProtocol: UIViewController {
}

enum Sections: Int {
    case news = 0
    case loadingSpinner = 1
}

enum DisplayItemType: Equatable {
    case item(id: Int)
    case loadingSpinner
}

class NewsFeedViewController: UIViewController, NewsFeedViewProtocol {
    private let viewModel: NewsFeedViewModelProtocol
    private let refreshControl = UIRefreshControl()
    private var data: [NewsItemModel] = []
    private var subscribers = Set<AnyCancellable>()
    private var rootView: NewsFeedView?
    private var hasMoreData: Bool = false
    
    init(viewModel: NewsFeedViewModelProtocol) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        let view = NewsFeedView()
        
        self.rootView = view
        setupCollectionView()
        self.view = view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        subscribeToPublishers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel.updateViewVisibility(isVisible: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        viewModel.updateViewVisibility(isVisible: false)
    }
    
    private func subscribeToPublishers() {
        viewModel.dataPublisher
            .sink { [weak self] items in
                guard let self else { return }
                
                self.refreshControl.endRefreshing()
                
                let currentCount = self.data.count
                let newCount = items.count
                
                self.data = items
                if newCount > currentCount {
                    self.rootView?.collectionView.insertItems(at: (currentCount ..< newCount).map { IndexPath(row: $0, section: Sections.news.rawValue) })
                } else if currentCount > newCount {
                    self.rootView?.collectionView.deleteItems(at: (newCount ..< currentCount).map { IndexPath(row: $0, section: Sections.news.rawValue) })
                }
            }
            .store(in: &subscribers)
        
        viewModel.statePublisher
            .sink { [weak self] state in
                guard let self else { return }
                
                var isLoading = false
                
                switch state {
                case .error(let error):
                    self.rootView?.showError(message: error.localizedDescription)
                case .loading:
                    self.rootView?.hideError()
                    isLoading = true
                case .idle:
                    self.rootView?.hideError()
                }
                
                if self.hasMoreData != isLoading {
                    self.hasMoreData = isLoading
                    
                    if isLoading {
                        self.rootView?.collectionView.insertSections(IndexSet(integer: Sections.loadingSpinner.rawValue))
                    } else {
                        self.rootView?.collectionView.deleteSections(IndexSet(integer: Sections.loadingSpinner.rawValue))
                    }
                }
            }
            .store(in: &subscribers)
        
        rootView?.tryAgainButtonPublisher
            .sink { [weak self] in
                self?.viewModel.tryAgain()
            }
            .store(in: &subscribers)
    }
    
    private func setupCollectionView() {
        guard let collectionView = rootView?.collectionView else { return }
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        let layout = UICollectionViewCompositionalLayout { [weak self] sectionIndex, environment in
            guard let self else { return nil }
            
            if sectionIndex == 0 {
                return self.getNewsFeedItemsSectionLayout()
            } else {
                return self.getLoadingSectionLayout()
            }
        }
        
        collectionView.collectionViewLayout = layout
        
        collectionView.register(UINib(nibName: "NewsFeedItemCell", bundle: nil), forCellWithReuseIdentifier: "\(NewsFeedItemCell.self)")
        collectionView.register(UINib(nibName: "SpinnerCell", bundle: nil), forCellWithReuseIdentifier: "SpinnerCell")
        
        refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
       collectionView.refreshControl = refreshControl
    }
    
    @objc private func didPullToRefresh() {
        viewModel.reloadData()
    }
    
    private func getNewsFeedItemsSectionLayout() -> NSCollectionLayoutSection {
        if UIDevice.current.userInterfaceIdiom == .pad {
            let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(150)))
            let itemGroup = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .absolute(150)), subitems: [item])
            let rowGroup = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(150)), subitems: [itemGroup, itemGroup])
            
            return NSCollectionLayoutSection(group: rowGroup)
        } else {
            let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(150)))
            let group = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(150)), subitems: [item])
            
            return NSCollectionLayoutSection(group: group)
        }
    }
    
    private func getLoadingSectionLayout() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(50)))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(50)), subitems: [item])
        
        return NSCollectionLayoutSection(group: group)
    }
}

extension NewsFeedViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        section == Sections.news.rawValue ? data.count : 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == Sections.loadingSpinner.rawValue {
            return collectionView.dequeueReusableCell(withReuseIdentifier: "SpinnerCell", for: indexPath)
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(NewsFeedItemCell.self)", for: indexPath)
        if let newsFeedItemCell = cell as? NewsFeedItemCell {
            newsFeedItemCell.set(item: data[indexPath.row])
        }
        
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        hasMoreData ? 2 : 1
    }

}

extension NewsFeedViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        let item: DisplayItemType
        if indexPath.section == Sections.news.rawValue {
            item = .item(id: data[indexPath.row].id)
        } else {
            item = .loadingSpinner
        }
        
        viewModel.didShowItem(item: item)    
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == Sections.news.rawValue {
            viewModel.didSelectItem(id: data[indexPath.row].id)
        }
    }
}
