//
//  PhotoPickerCell.swift
//  ZXPhotoPicker
//
//  Created by Zhe Xian Lee on 25/11/17.
//
import UIKit
import Photos

open class PhotoPickerCell: UICollectionViewCell {
    
    static let reuseIdentifier = "PhotoPickerCell"
    
    var imageView: UIImageView!
    
    var loadImageOperation: Operation?
    
    var asset: PHAsset? 
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        let imageViewWidthConstraint = NSLayoutConstraint(item: imageView, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 1, constant: 0)
        let imageViewHeightContraint = NSLayoutConstraint(item: imageView, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 1, constant: 0)
        let iamgeViewXContraint = NSLayoutConstraint(item: imageView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0)
        let imageViewYConstraint = NSLayoutConstraint(item: imageView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0)
        
        contentView.addSubview(imageView)
        addConstraints([imageViewWidthConstraint, imageViewHeightContraint, iamgeViewXContraint, imageViewYConstraint])
        
    }
}
