//
//  ImageInterfaceController.swift
//  DucWatchApp2 WatchKit Extension
//
//  Created by pham.dinh.duc on 1/8/20.
//  Copyright © 2020 Watch. All rights reserved.
//

import WatchKit
import Foundation
import UIKit
import ImageIO


class ImageInterfaceController: WKInterfaceController {
    @IBOutlet var image: WKInterfaceImage!
    @IBOutlet var image2: WKInterfaceImage!


    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
//        image.setImageNamed("A_Lowest_01")
//        image.startAnimatingWithImages(in: NSRange.init(location: 0, length: 10), duration: 2, repeatCount: 1)
        
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        let frames = UIImage.animatedImageNamed("A_Lowest_01", duration: 12)
//        image.setImage(frames)
        let uiimage = UIImage(named: "A_Lowest_01")!

        let images = getSequence(gifNamed: "A_Lowest_01")
        
//        image.startAnimatingWithImages(in: NSRange.init(location: 0, length: 31), duration: 2, repeatCount: 0)

        image2.setImageNamed("giphy")
        image2.startAnimatingWithImages(in: NSRange.init(location: 0, length: 9), duration: 2, repeatCount: 0)
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    func getSequence(gifNamed: String) -> [UIImage]? {
        var bundleURL2: URL?
        Bundle.allBundles.forEach { (bundle) in
            print(bundle.description)
            if let url = bundle.url(forResource: gifNamed, withExtension: "png") {
                bundleURL2 = bundle.url(forResource: gifNamed, withExtension: "png")
            }
        }
        guard let bundleURL = bundleURL2 else {
            return nil
        }

//        guard let bundleURL = Bundle.main
//            .url(forResource: gifNamed, withExtension: "png") else {
//                print("This image named \"\(gifNamed)\" does not exist!")
//                return nil
//        }
//

        guard let imageData = try? Data(contentsOf: bundleURL) else {
            print("Cannot turn image named \"\(gifNamed)\" into NSData")
            return nil
        }

        let gifOptions = [
            kCGImageSourceShouldAllowFloat as String : true as NSNumber,
            kCGImageSourceCreateThumbnailWithTransform as String : true as NSNumber,
            kCGImageSourceCreateThumbnailFromImageAlways as String : true as NSNumber
            ] as CFDictionary

        guard let imageSource = CGImageSourceCreateWithData(imageData as CFData, gifOptions) else {
            debugPrint("Cannot create image source with data!")
            return nil
        }

        let framesCount = CGImageSourceGetCount(imageSource)
        var frameList = [UIImage]()

        for index in 0 ..< framesCount {

            if let cgImageRef = CGImageSourceCreateImageAtIndex(imageSource, index, nil) {
                let uiImageRef = UIImage(cgImage: cgImageRef)
                frameList.append(uiImageRef)
            }

        }

        return frameList // Your gif frames is ready
    }
}
