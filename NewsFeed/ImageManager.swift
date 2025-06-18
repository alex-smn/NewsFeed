//
//  ImageManager.swift
//  NewsFeed
//
//  Created by Alexander Livshits on 17/06/2025.
//

import Combine
import Foundation
import UIKit

protocol ImageManagerProtocol {
    func getImage(from url: URL) -> AnyPublisher<UIImage?, Never>
    func loadImage(from url: URL) async
}

class ImageManager: ImageManagerProtocol {
    private let dataStorage: DataStorageProtocol
    private let networkImageSubject = PassthroughSubject<(key: String, image: UIImage?), Never>()
    
    init(dataStorage: DataStorageProtocol) {
        self.dataStorage = dataStorage
    }
    
    func getImage(from url: URL) -> AnyPublisher<UIImage?, Never> {
        let initialImagePublisher = Future<UIImage?, Never> { [weak self] promise in
            Task {
                if let data = await self?.loadFromCache(key: url.absoluteString) {
                    let image = UIImage(data: data)
                    promise(.success(image))
                } else {
                    promise(.success(nil))
                }
            }
        }
        
        let networkImagePublisher = networkImageSubject.filter { $0.key == url.absoluteString }.map { $0.image }
        
        return initialImagePublisher
            .merge(with: networkImagePublisher)
            .eraseToAnyPublisher()
    }
    
    func loadImage(from url: URL) async {
        if
            let data = await loadFromCache(key: url.absoluteString),
            UIImage(data: data) != nil
        {
            return
        } else {
            await loadImageFromNetwork(from: url)
        }
    }
    
    private func loadImageFromNetwork(from url: URL) async {
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            await saveToCache(key: url.absoluteString, imageData: data)
            let image = UIImage(data: data)
            networkImageSubject.send((key: url.absoluteString, image: image))
        } catch {
            print("Failed to load image:", error.localizedDescription) // TODO: handle error
        }
    }
    
    private func saveToCache(key: String, imageData: Data) async {
        await dataStorage.save(key: key, data: imageData)
    }
    
    private func loadFromCache(key: String) async -> Data? {
        await dataStorage.load(key: key)
    }
}
