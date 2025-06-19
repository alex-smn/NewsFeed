//
//  SceneDelegate.swift
//  NewsFeed
//
//  Created by Alexander Livshits on 17/06/2025.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    private var appCoordinator = AppCoordinator()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = appCoordinator.viewController
            
            self.window = window
            window.makeKeyAndVisible()
        }
    }
}

