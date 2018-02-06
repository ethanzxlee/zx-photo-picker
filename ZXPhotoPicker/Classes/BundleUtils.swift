//
//  BundleExtensions.swift
//  ZXPhotoPicker
//
//  Created by Zhe Xian Lee on 26/11/17.
//

import Foundation

class BundleUtils {
    
    static var frameworkBundle: Bundle {
        return Bundle(for: BundleUtils.self)
    }
    
    static var assetBundle: Bundle? {
        let assetBundleURL = frameworkBundle.resourceURL!.appendingPathComponent("ZXPhotoPicker.bundle")
        let assetBundle = Bundle(url: assetBundleURL)
        return assetBundle
    }
    
}

