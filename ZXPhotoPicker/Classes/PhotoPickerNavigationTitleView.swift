//
//  PhotoPickerNavigationTitleView.swift
//  ZXPhotoPicker
//
//  Created by Zhe Xian Lee on 26/11/17.
//

import UIKit

class PhotoPickerNavigationTitleView: UIView {
    
    var title: String = "All Photos" {
        didSet {
            albumTitleLabel?.text = title
        }
    }
    
    var albumTitleLabel: UILabel!
    
    var caretView: UIImageView!
    
    var isExpanded: Bool = false {
        didSet {
            UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.45, initialSpringVelocity: 1, options: [], animations: {
                self.caretView?.transform = self.caretView.transform.rotated(by: .pi)
            }, completion: nil)
        }
    }
    
    init() {
        super.init(frame: CGRect.zero)
        setupView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    func setupView() {
        self.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        
        albumTitleLabel = UILabel(frame: CGRect.zero)
        albumTitleLabel.text = title
        albumTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        albumTitleLabel.font = UIFont.boldSystemFont(ofSize: UIFont.labelFontSize)
        
        let caretImage = UIImage(named: "caret", in: BundleUtils.assetBundle, compatibleWith: nil)
        caretView = UIImageView(image: caretImage)
        caretView.contentMode = .scaleAspectFit
        caretView.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(albumTitleLabel)
        self.addSubview(caretView)
        
        self.addConstraints([
            NSLayoutConstraint(item: albumTitleLabel, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: albumTitleLabel, attribute: .trailing, relatedBy: .equal, toItem: caretView, attribute: .leading, multiplier: 1, constant: -5),
            NSLayoutConstraint(item: albumTitleLabel, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: albumTitleLabel, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0),
            
            NSLayoutConstraint(item: caretView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 10),
            NSLayoutConstraint(item: caretView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 44),
            NSLayoutConstraint(item: caretView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: caretView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0)
        ])
        
    }

}
