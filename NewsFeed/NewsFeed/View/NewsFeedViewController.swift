//
//  NewsFeedViewController.swift
//  NewsFeed
//
//  Created by Alexander Livshits on 16/06/2025.
//

import Combine
import UIKit

protocol NewsFeedViewProtocol {
    var visibilityPublisher: AnyPublisher<Bool, Never> { get }
    var visibleItemsPublisher: AnyPublisher<[Int], Never> { get }
    var selectedItemPublisher: AnyPublisher<Int, Never> { get }
}

class NewsFeedViewController: UIViewController {
    private let viewModel: NewsFeedViewModelProtocol
    private var data: [NewsItemModel] = []
    private var state: NewsFeedViewModelState = .idle
    private var subscribers = Set<AnyCancellable>()
    private var collectionView: UICollectionView?
    
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
    
    private func subscribeToPublishers() {
        viewModel.dataPublisher
            .sink {[weak self] items in
                guard let self else { return }
                
                self.data = items
                self.collectionView?.reloadData()
            }
            .store(in: &subscribers)
        
        viewModel.statePublisher
            .sink {[weak self] state in
                guard let self else { return }
                
                self.state = state
                self.collectionView?.reloadData()
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
    }
    
    private func getNewsFeedItemsSectionLayout() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(150)))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(150)), subitems: [item])
        
        return NSCollectionLayoutSection(group: group)
    }
    
    private func getLoadingSectionLayout() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(50)))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(50)), subitems: [item])
        
        return NSCollectionLayoutSection(group: group)
    }
}

extension NewsFeedViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(NewsFeedItemCell.self)", for: indexPath)
        if let newsFeedItemCell = cell as? NewsFeedItemCell {
            newsFeedItemCell.set(item: data[indexPath.row])
        }
        
        return cell
    }
}

extension NewsFeedViewController: UICollectionViewDelegate {
    
}
