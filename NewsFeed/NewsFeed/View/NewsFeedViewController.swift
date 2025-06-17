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
    var itemSelectionPublisher: AnyPublisher<Int, Never> { get }
}

class NewsFeedViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        print("works")
    }
}

