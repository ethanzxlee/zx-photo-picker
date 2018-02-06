//
//  PhotoPickerCell.swift
//  ZXPhotoPicker
//
//  Created by Zhe Xian Lee on 25/11/17.
//
import UIKit

open class PhotoPickerCell: UICollectionViewCell {
    
    static let reuseIdentifier = "PhotoPickerCell"
    
    var label: UILabel!
    
    var imageView: UIImageView!

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
        
        label = UILabel()
        label.text = "omg"
        
        backgroundColor = .yellow
        
        contentView.addSubview(imageView)
        contentView.addSubview(label)
    }
}
