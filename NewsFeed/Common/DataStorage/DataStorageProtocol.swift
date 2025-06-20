//
//  DataStorageProtocol.swift
//  NewsFeed
//
//  Created by Alexander Livshits on 20/06/2025.
//

import Foundation

protocol DataStorageProtocol {
    func save(key: String, data: Data) async
    func load(key: String) async -> Data?
}
