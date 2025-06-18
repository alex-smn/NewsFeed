//
//  DataStorage.swift
//  NewsFeed
//
//  Created by Alexander Livshits on 18/06/2025.
//

import Foundation
import UIKit

protocol DataStorageProtocol {
    func save(key: String, data: Data) async
    func load(key: String) async -> Data?
}

class LocalDataStorage: DataStorageProtocol {
    private var storage = [String : Data]() // TODO: consider saving to persistent storage instead
    
    func save(key: String, data: Data) async {
        storage[key] = data
    }
    
    func load(key: String) async -> Data? {
        storage[key]
    }
}
