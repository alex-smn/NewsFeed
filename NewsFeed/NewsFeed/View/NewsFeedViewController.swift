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
    let viewModel = NewsFeedViewModel()
    
    override func loadView() {
        let view = NewsFeedView()
        
        self.setup(collectionView: view.collectionView)
        self.view = view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    private func setup(collectionView: UICollectionView) {
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
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(150)))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(150)), subitems: [item])
        
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
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(NewsFeedItemCell.self)", for: indexPath)
        if let newsFeedItemCell = cell as? NewsFeedItemCell {
            newsFeedItemCell.titleLabel.text = "News Item Title"
        }
        
        return cell
    }
}

extension NewsFeedViewController: UICollectionViewDelegate {
    
}
