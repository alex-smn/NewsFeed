//
//  NewsFeedViewController.swift
//  NewsFeed
//
//  Created by Alexander Livshits on 16/06/2025.
//

import Combine
import UIKit

protocol NewsFeedViewProtocol: AnyObject {
    var visibilityPublisher: AnyPublisher<Bool, Never> { get }
    var visibleItemsPublisher: AnyPublisher<[DisplayItemType], Never> { get }
    var selectedItemPublisher: AnyPublisher<Int, Never> { get }
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
    var visibilityPublisher: AnyPublisher<Bool, Never> {
        $isVisible.eraseToAnyPublisher()
    }
    var visibleItemsPublisher: AnyPublisher<[DisplayItemType], Never> {
        $visibleItems.map { items in
            return items.compactMap { [weak self] indexPath -> DisplayItemType? in
                guard let self else { return nil }
                if indexPath.section == Sections.news.rawValue {
                    return DisplayItemType.item(id: self.data[indexPath.row].id)
                } else {
                    return DisplayItemType.loadingSpinner
                }
            }
        }.eraseToAnyPublisher()
    }
    var selectedItemPublisher: AnyPublisher<Int, Never> {
        selectedItemSubject.eraseToAnyPublisher()
    }
    
    @Published private var isVisible = false
    @Published private var visibleItems = Set<IndexPath>()
    
    private let viewModel: NewsFeedViewModelProtocol
    private let selectedItemSubject = PassthroughSubject<Int, Never>()
    private var data: [NewsItemModel] = []
    private var state: NewsFeedViewModelState = .idle
    private var subscribers = Set<AnyCancellable>()
    private var collectionView: UICollectionView?
    private var hasMoreData: Bool = false
    
    init(viewModel: NewsFeedViewModelProtocol) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
        
        subscribeToPublishers()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        let view = NewsFeedView()
        collectionView = view.collectionView
        
        setupCollectionView()
        self.view = view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isVisible = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        isVisible = false
    }
    
    private func subscribeToPublishers() {
        viewModel.dataPublisher
            .sink { [weak self] items in
                guard let self else { return }
                
                self.data = items
                self.collectionView?.reloadData()
            }
            .store(in: &subscribers)
        
        viewModel.statePublisher
            .sink { [weak self] state in
                guard let self else { return }
                
                self.state = state
            }
            .store(in: &subscribers)
        
        viewModel.hasMoreDataPublisher
            .sink { [weak self] in
                self?.hasMoreData = $0
            }
            .store(in: &subscribers)
    }

    private func setupCollectionView() {
        guard let collectionView else { return }
        
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
        visibleItems.insert(indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        visibleItems.remove(indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == Sections.news.rawValue {
            selectedItemSubject.send(data[indexPath.row].id)
        }
    }
}
