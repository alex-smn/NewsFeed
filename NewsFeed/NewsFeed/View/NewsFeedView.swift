//
//  NewsFeedView.swift
//  NewsFeed
//
//  Created by Alexander Livshits on 16/06/2025.
//

import Combine
import UIKit

class NewsFeedView: UIView {
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    
    private let errorView = NewsFeedErrorView.loadViewFromNib()
    private let tintView = UIView()
    
    var tryAgainButtonPublisher: AnyPublisher<Void, Never> {
        errorView.tryAgainButtonPublisher
    }
    
    init() {
        super.init(frame: .zero)
        
        self.backgroundColor = .white
        
        prepareUI()
        
        setupCollectionView()
        setupErrorView()
        setupTintView()
    }
    
    func showError(message: String) {
        errorView.label.text = message
        errorView.isHidden = false
        tintView.isHidden = false
    }
    
    func hideError() {
        errorView.isHidden = true
        tintView.isHidden = true
    }
    
    private func prepareUI() {
        addSubview(collectionView)
        addSubview(tintView)
        addSubview(errorView)
    }
    
    private func setupCollectionView() {
        collectionView.accessibilityIdentifier = "NewsFeedCollectionView"
        collectionView.backgroundColor = .white
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        collectionView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        collectionView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        collectionView.topAnchor.constraint(equalTo: self.layoutMarginsGuide.topAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: self.layoutMarginsGuide.bottomAnchor).isActive = true
    }
    
    private func setupErrorView() {
        errorView.label.text = ""
        errorView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        errorView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        errorView.isHidden = true
    }
    
    private func setupTintView() {
        tintView.backgroundColor = UIColor(white: 0, alpha: 0.5)
        tintView.translatesAutoresizingMaskIntoConstraints = false

        tintView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        tintView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        tintView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        tintView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

