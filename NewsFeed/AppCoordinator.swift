//
//  AppCoordinator.swift
//  NewsFeed
//
//  Created by Alexander Livshits on 19/06/2025.
//

import Foundation
import UIKit

protocol CoordinatorProtocol {
    var viewController: UIViewController { get }
    var navigationController: UINavigationController { get }
}

class AppCoordinator: CoordinatorProtocol {
    
    let newsFeedCoordinator: NewsFeedCoordinator
    let viewController: UIViewController
    let navigationController: UINavigationController
    
    init() {
        navigationController = UINavigationController()
        newsFeedCoordinator = NewsFeedCoordinator(navigationController: navigationController)
        
        navigationController.setViewControllers([newsFeedCoordinator.viewController], animated: false)
        viewController = navigationController
    }
}
