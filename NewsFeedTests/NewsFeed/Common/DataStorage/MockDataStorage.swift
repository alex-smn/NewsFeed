//
//  MockDataStorage.swift
//  NewsFeed
//
//  Created by Alexander Livshits on 20/06/2025.
//

import Foundation
import UIKit

class MockDataStorage: DataStorageProtocol {
    var storage = [String : Data]()
    
    func save(key: String, data: Data) async {
        storage[key] = data
    }
    
    func load(key: String) async -> Data? {
        storage[key]
    }
}
