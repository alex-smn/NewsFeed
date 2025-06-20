//
//  DataStorage.swift
//  NewsFeed
//
//  Created by Alexander Livshits on 18/06/2025.
//

import Foundation
import UIKit

class LocalDataStorage: DataStorageProtocol {
    private var storage = [String : Data]()
    
    func save(key: String, data: Data) async {
        storage[key] = data
    }
    
    func load(key: String) async -> Data? {
        storage[key]
    }
}
