//
//  NewsFeedCoordinator.swift
//  NewsFeed
//
//  Created by Alexander Livshits on 18/06/2025.
//

import Foundation
import UIKit
import WebKit

class NewsFeedCoordinator: CoordinatorProtocol {
    let newsFeedViewModel: NewsFeedViewModelProtocol
    let viewController: UIViewController
    let navigationController: UINavigationController
    let imageManager: ImageManager

    let localDataStorage = LocalDataStorage()
    
    init(navigationController: UINavigationController) {
        let webNewsFeedRepository = WebNewsFeedRepository()
        imageManager = ImageManager(dataStorage: localDataStorage)
        
        let viewModel = NewsFeedViewModel(repository: webNewsFeedRepository, imageManager: imageManager)
        
        newsFeedViewModel = viewModel
        viewController = NewsFeedViewController(viewModel: newsFeedViewModel)
        self.navigationController = navigationController
        
        viewModel.navigateToArticle = { [weak self] url in
            guard let self else { return }
            
            let viewController = prepareWebView(url: url)
            
            self.navigationController.pushViewController(viewController, animated: true)
        }
    }
    
    private func prepareWebView(url: URL) -> UIViewController {
        let viewController = UIViewController()
        let webView = WKWebView(frame: UIScreen.main.bounds)
        viewController.view.addSubview(webView)
        
        webView.load(URLRequest(url: url))
        webView.allowsBackForwardNavigationGestures = true
        
        return viewController
    }
}
