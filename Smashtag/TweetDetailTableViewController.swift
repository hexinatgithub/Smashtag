//
//  TweetDetailTableViewController.swift
//  Smashtag
//
//  Created by 何鑫 on 16/2/21.
//  Copyright © 2016年 Stanford University. All rights reserved.
//

import UIKit

class TweetDetailTableViewController: UITableViewController {

    // MARK: Modal
    var sections: Int = 4           { didSet{ tableView.setNeedsDisplay()} }
    var images: [UIImage]? {
        didSet{
            tableView.setNeedsDisplay()
            rowsInSection[SectionIdentifier.ImagesSection.rawValue] = images?.count ?? 0
        }
    }
    var urls: [String]? {
        didSet{
            tableView.setNeedsDisplay()
            rowsInSection[SectionIdentifier.UrlsSection.rawValue] = urls?.count ??  0
        }
    }
    var hashtags: [String]? {
        didSet{
            tableView.setNeedsDisplay()
            rowsInSection[SectionIdentifier.Hashtag.rawValue] = hashtags?.count ??  0
        }
    }
    var users: [String]? {
        didSet{
            tableView.setNeedsDisplay()
            rowsInSection[SectionIdentifier.Users.rawValue] = users?.count ??  0
        }
    }
    var rowsInSection = [Int](count: 4, repeatedValue: 0)
    var tweet: Tweet! {
        didSet {
            if tweet != nil {
                images = [UIImage](count: tweet.media.count, repeatedValue: UIImage())
                for i in 0..<tweet.media.count {
                    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {
                        let data = NSData(contentsOfURL: self.tweet.media[i].url)!
                        dispatch_async(dispatch_get_main_queue()) {
                            self.images?[i] =  UIImage(data: data)!
                        }
                    }
                }
                urls = tweet.urls.count == 0 ? nil : tweet.urls.map { $0.keyword }
                hashtags = tweet.hashtags.count == 0 ? nil : tweet.hashtags.map { $0.keyword }
                users = tweet.userMentions.count == 0 ? nil : tweet.userMentions.map { $0.keyword }
            }
        }
    }
    var presentedVC: TweetTableViewController!
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            if identifier == Storyboard.TweetImage {
                let tivc = segue.destinationViewController as! TweetImageViewController
                let selected = sender as! SelectedIndexPath
                tivc.image = images![selected.row]
            }
        }
    }
    
    // MARK: ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    // MARK: - Table delegate
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let sectionIdentifier = SectionIdentifier(rawValue: indexPath.section) {
            switch sectionIdentifier {
            case .Hashtag:
                let ttvc = self.presentedVC
                ttvc.searchText = hashtags![indexPath.row]
                navigationController?.popViewControllerAnimated(true)
            case .Users:
                let ttvc = self.presentedVC
                ttvc.searchText = users![indexPath.row]
                navigationController?.popViewControllerAnimated(true)
            case .UrlsSection:
                if let url = NSURL(string: urls![indexPath.row]) {
                    UIApplication.sharedApplication().openURL(url)
                }
            case .ImagesSection:
                let selected = SelectedIndexPath(section: indexPath.section, row: indexPath.row)
                performSegueWithIdentifier(Storyboard.TweetImage, sender: selected)
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return sections
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return rowsInSection[section]
    }
    
    private enum SectionIdentifier: Int {
        case ImagesSection = 0, UrlsSection, Hashtag, Users
    }
    
    private struct SectionHeader {
        static let ImagesSection = "Image"
        static let UrlsSection = "URL"
        static let Hashtag = "Hashtag"
        static let Users = "Users"
    }
    
    private struct Storyboard {
        static let ImageCell = "ImageCell"
        static let LabelCell = "LabelCell"
        static let TweetImage = "TweetImage"
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let sectionIdentifier = SectionIdentifier(rawValue: section) {
            switch sectionIdentifier {
            case .ImagesSection:
                return rowsInSection[section] == 0 ? nil : SectionHeader.ImagesSection
            case .UrlsSection:
                return rowsInSection[section] == 0 ? nil : SectionHeader.UrlsSection
            case .Hashtag:
                return rowsInSection[section] == 0 ? nil : SectionHeader.Hashtag
            case .Users:
                return rowsInSection[section] == 0 ? nil : SectionHeader.Users
            }
        }
        return nil
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let sectionIdentifier = SectionIdentifier(rawValue: indexPath.section) {
            switch sectionIdentifier {
            case .ImagesSection:
                if let image = images?[indexPath.row] {
                    let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.ImageCell) as! ImageTableViewCell
                    cell.pictureView.image = image
                    return cell
                }
            case .UrlsSection:
                if let url = urls?[indexPath.row] {
                    let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.LabelCell) as! LabelTableViewCell
                    cell.label.text = url
                    return cell
                }
            case .Users:
                if let usr = users?[indexPath.row] {
                    let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.LabelCell) as! LabelTableViewCell
                    cell.label.text = usr
                    return cell
                }
            case .Hashtag:
                if let hashtag = hashtags?[indexPath.row] {
                    let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.LabelCell) as! LabelTableViewCell
                    cell.label.text = hashtag
                    return cell
                }
            }
        }
        
        return UITableViewCell()
    }

}


class ImageTableViewCell: UITableViewCell {
    
    @IBOutlet weak var pictureView: UIImageView!
    
}

class LabelTableViewCell: UITableViewCell {
    
    @IBOutlet weak var label: UILabel!
    
}
