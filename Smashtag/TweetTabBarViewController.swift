//
//  TweetTabBarViewController.swift
//  Smashtag
//
//  Created by 何鑫 on 16/2/22.
//  Copyright © 2016年 Stanford University. All rights reserved.
//

import UIKit

class TweetTabBarViewController: UITabBarController {

    var tweetTableViewController: TweetTableViewController {
        let nvc = self.viewControllers!.first as! UINavigationController
        let vc = nvc.viewControllers.first as! TweetTableViewController
        return vc
    }

    var historyTableViewController: HistoryTableViewController {
        let hvc = self.viewControllers![1] as! HistoryTableViewController
        return hvc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        historyTableViewController.tweetTableViewController = tweetTableViewController
    }
    
}
