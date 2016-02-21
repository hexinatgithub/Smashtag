//
//  TweetImageViewController.swift
//  Smashtag
//
//  Created by 何鑫 on 16/2/21.
//  Copyright © 2016年 Stanford University. All rights reserved.
//

import UIKit

class TweetImageViewController: UIViewController, UIScrollViewDelegate {
    
    // MARK: -Image
    var image: UIImage! {
        didSet {
            imageView.image = image
            imageView.sizeToFit()
            scrollView.contentSize = imageView.bounds.size
        }
    }
    
    // MARK: -UIView
    
    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            scrollView.contentSize = imageView.frame.size
            scrollView.delegate = self
            scrollView.minimumZoomScale = 0.5
            scrollView.maximumZoomScale = 1.0
        }
    }
    var imageView = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.addSubview(imageView)
    }
    
    // MARK: -UIScrollViewDelegate
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
