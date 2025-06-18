//
//  Utility.swift
//  NewsFeed
//
//  Created by Alexander Livshits on 18/06/2025.
//

import UIKit

extension UIImage {
    func scaledTo(height: CGFloat) -> UIImage? {
        let size = CGSize(width: size.width * height / size.height, height: height)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
