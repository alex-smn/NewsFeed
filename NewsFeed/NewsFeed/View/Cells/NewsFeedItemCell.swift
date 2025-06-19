//
//  NewsFeedItemCell.swift
//  NewsFeed
//
//  Created by Alexander Livshits on 17/06/2025.
//

import Combine
import UIKit

class NewsFeedItemCell: UICollectionViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    private var imageSubscriber: AnyCancellable?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        titleLabel.text = ""
        imageView.image = UIImage(systemName: "photo.fill")
        imageSubscriber = nil
    }
    
    func set(item: NewsItemModel) {
        titleLabel.text = item.title
        imageSubscriber = item.imagePublisher.sink(receiveValue: { [weak self] image in
            self?.imageView.image = image ?? UIImage(systemName: "photo.fill")
        })
    }
}
