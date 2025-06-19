//
//  NewsFeedErrorView.swift
//  NewsFeed
//
//  Created by Alexander Livshits on 19/06/2025.
//

import Combine
import Foundation
import UIKit

class NewsFeedErrorView: UIView {
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = cornerRadius > 0
        }
    }

    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }

    @IBInspectable var borderColor: UIColor? {
        didSet {
            layer.borderColor = borderColor?.cgColor
        }
    }
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var tryAgainButton: UIButton!
    @IBAction func tryAgainButtonClicked(_ sender: Any) {
        tryAgainButtonSubject.send(())
    }
    
    private let tryAgainButtonSubject = PassthroughSubject<Void, Never>()
    
    var tryAgainButtonPublisher: AnyPublisher<Void, Never> {
        tryAgainButtonSubject.eraseToAnyPublisher()
    }
    
    static func loadViewFromNib() -> Self {
        let bundle = Bundle(for: Self.self)
        let nib = UINib(nibName: String(describing: Self.self), bundle: bundle)
        let nibView = nib.instantiate(withOwner: self, options: nil).first as! Self
        
        return nibView
    }
}
