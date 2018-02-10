//
//  PhotoPickerViewController.swift
//  ZXPhotoPicker
//
//  Created by Zhe Xian Lee on 25/11/17.
//

import UIKit
import Photos

open class PhotoPickerViewController: UIViewController {
    
    // UI
    
    var navigationBar: UINavigationBar!
    
    var navigationBarBlurEffectView: UIVisualEffectView!
    
    var assetsCollectionView: UICollectionView!
    
    var activityIndicatorView: UIActivityIndicatorView!
    
    var albumTableView: UITableView?
    
    var permissionDeniedView: UIView?
    
    var titleViewTapGestureRecogniser: UITapGestureRecognizer!
    
    var assetsFetchResult: PHFetchResult<PHAsset>?
    
    // Flags
    
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
        assetsCollectionView.alwaysBounceVertical = true
        
        navigationBar = UINavigationBar()
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        navigationBar.backgroundColor = UIColor.clear
        navigationBar.barTintColor = UIColor.clear
        navigationBar.isTranslucent = true
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        
        navigationBarBlurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .prominent))
        navigationBarBlurEffectView.translatesAutoresizingMaskIntoConstraints = false
        
        activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        activityIndicatorView?.hidesWhenStopped = true
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorView.color = .black
        activityIndicatorView.stopAnimating()
        
        titleViewTapGestureRecogniser = UITapGestureRecognizer(target: self, action: #selector(titleViewWasTapped(sender:)))
        
        let navItem = UINavigationItem()
        navItem.titleView = PhotoPickerNavigationTitleView()
        navItem.titleView?.addGestureRecognizer(titleViewTapGestureRecogniser)
        navigationBar.pushItem(navItem, animated: true)
        navigationBar.topItem?.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonWasPressed(sender:)))
        
        albumTableView = UITableView()
        albumTableView?.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        albumTableView?.dataSource = self
        
        self.view.addSubview(assetsCollectionView)
        self.view.addSubview(navigationBarBlurEffectView)
        self.view.addSubview(navigationBar)
        self.view.addSubview(activityIndicatorView)
        
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
                NSLayoutConstraint(item: navigationBarBlurEffectView, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0),
                
                // ActivityIndicatorView
                NSLayoutConstraint(item: activityIndicatorView, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: activityIndicatorView, attribute: .centerY, relatedBy: .equal, toItem: self.view, attribute: .centerY, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: activityIndicatorView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 40),
                NSLayoutConstraint(item: activityIndicatorView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 40)
            ])
        } else {
            // TODO: Fallback on earlier versions
        }
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        assetsCollectionView.dataSource = self
        assetsCollectionView.delegate = self
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 1
        flowLayout.minimumInteritemSpacing = 1
        
        let targetWidth = (UIScreen.main.bounds.width - 2) / 3 
        flowLayout.itemSize = CGSize(width: targetWidth, height: targetWidth)
        assetsCollectionView.collectionViewLayout = flowLayout
        
        PHPhotoLibrary.requestAuthorization({ (status) in
            if status == .authorized {
                DispatchQueue.main.async {
                    self.activityIndicatorView.startAnimating()
                }
                self.fetchAssets()
            }
            else {
                self.showPermissionDeniedView()
            }
        })
    }
    
    open override func viewDidLayoutSubviews() {
        // Make the collection view's content starts below the navbar
        assetsCollectionView.contentInset = UIEdgeInsets(top: navigationBar.frame.height, left: 0, bottom: 0, right: 0)
    }
    
    func fetchAssets() {
        let fetchOption = PHFetchOptions()
        fetchOption.sortDescriptors = [NSSortDescriptor(keyPath: \PHAsset.creationDate, ascending: false)]
        assetsFetchResult = PHAsset.fetchAssets(with: fetchOption)
        
        DispatchQueue.main.async {
            self.assetsCollectionView.reloadData()
            self.activityIndicatorView.stopAnimating()
            PHPhotoLibrary.shared().register(self)
        }
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

    @objc func titleViewWasTapped(sender: UITapGestureRecognizer) {
        isAlbumTableViewExpanded = !isAlbumTableViewExpanded
    }
    
    @objc func cancelButtonWasPressed(sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
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
        
        guard let photoCell = cell as? PhotoPickerCell else {
            return cell
        }
        
        photoCell.loadImageOperation?.cancel()
        
        photoCell.imageView.image = nil
        photoCell.loadImageOperation = nil
        photoCell.asset = nil
        
        photoCell.asset = assetsFetchResult![indexPath.item]
        photoCell.loadImageOperation = BlockOperation {
            PHImageManager.default().requestImage(for: photoCell.asset!, targetSize: photoCell.frame.size, contentMode: .aspectFill, options: nil) { (image, info) in
                photoCell.imageView.image = image
            }
        }
        photoCell.loadImageOperation!.start()
        
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

extension PhotoPickerViewController: PHPhotoLibraryChangeObserver {
    
    public func photoLibraryDidChange(_ changeInstance: PHChange) {
        
    }
    
}
