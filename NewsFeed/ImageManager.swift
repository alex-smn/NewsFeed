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
    func getImagePublisher(from url: URL) -> AnyPublisher<UIImage?, Never>
    func loadImage(from url: URL) async
}

class ImageManager: ImageManagerProtocol {
    private let dataStorage: DataStorageProtocol
    private let networkImageSubject = PassthroughSubject<(key: String, image: UIImage?), Never>()
    
    init(dataStorage: DataStorageProtocol) {
        self.dataStorage = dataStorage
    }
    
    func getImagePublisher(from url: URL) -> AnyPublisher<UIImage?, Never> {
        let initialImagePublisher = CurrentValueSubject<Void, Never>(()).map { [weak self] _ in
            Future<UIImage?, Never> { [weak self] promise in
                Task {
                    if let data = await self?.loadFromCache(key: url.absoluteString) {
                        let image = UIImage(data: data)
                        promise(.success(image))
                    } else {
                        promise(.success(nil))
                    }
                }
            }
        }
            .switchToLatest()
        
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
            let image = UIImage(data: data)?.scaledTo(height: Constants.newsItemImageHeight)
            await saveToCache(key: url.absoluteString, imageData: image?.pngData() ?? data)
            
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
