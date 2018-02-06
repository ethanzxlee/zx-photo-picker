//
//  PhotoPickerViewController.swift
//  ZXPhotoPicker
//
//  Created by Zhe Xian Lee on 25/11/17.
//

import UIKit
import Photos

open class PhotoPickerViewController: UIViewController {
    
    var navigationBar: UINavigationBar!
    
    var navigationBarBlurEffectView: UIVisualEffectView!
    
    var assetsCollectionView: UICollectionView!
    
    var titleViewTapGestureRecogniser: UITapGestureRecognizer!
    
    var albumTableView: UITableView?
    
    var permissionDeniedView: UIView?
    
    var assetsFetchResult: PHFetchResult<PHAsset>?
    
    var isAlbumTableViewExpanded: Bool = false {
        didSet {
            guard let titleView = navigationBar.topItem?.titleView as? PhotoPickerNavigationTitleView
                else {
                    return
            }
            titleView.isExpanded = isAlbumTableViewExpanded
        }
    }
    
    open override func loadView() {
        super.loadView()
        
        assetsCollectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: PhotoPickerViewLayout())
        assetsCollectionView.register(PhotoPickerCell.self, forCellWithReuseIdentifier: PhotoPickerCell.reuseIdentifier)
        assetsCollectionView.translatesAutoresizingMaskIntoConstraints = false
        assetsCollectionView.backgroundColor = UIColor.white
        
        navigationBar = UINavigationBar()
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        navigationBar.backgroundColor = UIColor.clear
        navigationBar.barTintColor = UIColor.clear
        navigationBar.isTranslucent = true
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        
        navigationBarBlurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .prominent))
        navigationBarBlurEffectView.translatesAutoresizingMaskIntoConstraints = false
        
        titleViewTapGestureRecogniser = UITapGestureRecognizer(target: self, action: #selector(handleTitleViewTap(sender:)))
        let navItem = UINavigationItem()
        navItem.titleView = PhotoPickerNavigationTitleView()
        navItem.titleView?.addGestureRecognizer(titleViewTapGestureRecogniser)
        navigationBar.pushItem(navItem, animated: true)
        
        albumTableView = UITableView()
        albumTableView?.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        albumTableView?.dataSource = self
        
        self.view.addSubview(assetsCollectionView)
        self.view.addSubview(navigationBarBlurEffectView)
        self.view.addSubview(navigationBar)
        
        if #available(iOS 11.0, *) {
            self.view.addConstraints([
                // CollectionView
                NSLayoutConstraint(item: assetsCollectionView, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: assetsCollectionView, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: assetsCollectionView, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: assetsCollectionView, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1, constant: 0),
                
                // NavigationBar
                NSLayoutConstraint(item: navigationBar, attribute: .top, relatedBy: .equal, toItem: self.view.safeAreaLayoutGuide, attribute: .top, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: navigationBar, attribute: .width, relatedBy: .equal, toItem: self.view, attribute: .width, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: navigationBar, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0),
                
                // NavigationBarBlurView
                NSLayoutConstraint(item: navigationBarBlurEffectView, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: navigationBarBlurEffectView, attribute: .bottom, relatedBy: .equal, toItem: navigationBar, attribute: .bottom, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: navigationBarBlurEffectView, attribute: .width, relatedBy: .equal, toItem: self.view, attribute: .width, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: navigationBarBlurEffectView, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0)
            ])
        } else {
            // TODO: Fallback on earlier versions
        }
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        assetsCollectionView.dataSource = self
        assetsCollectionView.delegate = self
        
        PHPhotoLibrary.requestAuthorization({ (status) in
            if status == .authorized {
                self.fetchAssets()
            }
            else {
                self.showPermissionDeniedView()
            }
        })
    }
    
    func fetchAssets() {
        assetsFetchResult = PHAsset.fetchAssets(with: PHFetchOptions())
        
        DispatchQueue.main.async {
            self.assetsCollectionView.reloadData()
        }
        
//        PHPhotoLibrary.shared().register(<#T##observer: PHPhotoLibraryChangeObserver##PHPhotoLibraryChangeObserver#>)
    }
    
    func showPermissionDeniedView() {
        print("denied")
    }
    
    func fetchAssetCollections(with type: PHAssetCollectionType) -> [PHAssetCollection] {
        let result = PHAssetCollection.fetchAssetCollections(with: type, subtype: .any, options: nil)
        let assetCollections = result.objects(at: IndexSet(0..<result.count))
        
        return assetCollections.filter { (assetCollection) -> Bool in
            assetCollection.estimatedAssetCount > 0
        }
    }

    @objc func handleTitleViewTap(sender: UITapGestureRecognizer) {
        isAlbumTableViewExpanded = !isAlbumTableViewExpanded
    }
}


extension PhotoPickerViewController: UICollectionViewDataSource {
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assetsFetchResult?.count ?? 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoPickerCell.reuseIdentifier, for: indexPath)
        return cell
    }
    
}


extension PhotoPickerViewController: UICollectionViewDelegate {
    
}


extension PhotoPickerViewController: UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        return cell
    }
    
    
}

