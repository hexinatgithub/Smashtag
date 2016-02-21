//
//  TweetTableViewCell.swift
//  Smashtag
//
//  Created by CS193p Instructor.
//  Copyright (c) 2015 Stanford University. All rights reserved.
//

import UIKit

class TweetTableViewCell: UITableViewCell
{
    var tweet: Tweet? {
        didSet {
            if tweet != nil {
                updateUI()
            }
        }
    }
    
    @IBOutlet weak var tweetProfileImageView: UIImageView!
    @IBOutlet weak var tweetScreenNameLabel: UILabel!
    @IBOutlet weak var tweetTextLabel: UILabel!
    @IBOutlet weak var tweetCreatedLabel: UILabel!
    
    func updateUI() {
        // reset any existing tweet information
        tweetTextLabel?.attributedText = nil
        tweetScreenNameLabel?.text = nil
        tweetProfileImageView?.image = nil
        tweetCreatedLabel?.text = nil
        
        // load new information from our tweet (if any)
        if let tweet = self.tweet
        {
            tweetTextLabel?.text = tweet.text
            if tweetTextLabel?.text != nil  {
                for _ in tweet.media {
                    tweetTextLabel.text! += " 📷"
                }
            }
            
            tweetScreenNameLabel?.text = "\(tweet.user)" // tweet.user.description
            
            if let profileImageURL = tweet.user.profileImageURL {
                if let imageData = NSData(contentsOfURL: profileImageURL) { // blocks main thread!
                    tweetProfileImageView?.image = UIImage(data: imageData)
                }
            }
            
            let formatter = NSDateFormatter()
            if NSDate().timeIntervalSinceDate(tweet.created) > 24*60*60 {
                formatter.dateStyle = NSDateFormatterStyle.ShortStyle
            } else {
                formatter.timeStyle = NSDateFormatterStyle.ShortStyle
            }
            tweetCreatedLabel?.text = formatter.stringFromDate(tweet.created)
        }
        
        // highlight
        highlight()
    }
    
    private func highlight() {
        highlight(keyword: .URL)
        highlight(keyword: .HashTag)
        highlight(keyword: .UserMentions)
    }
    
    private enum Keyword {
        case URL
        case HashTag
        case UserMentions
    }
    
    private func highlight(keyword keyword: Keyword) {
        var keywords: [Tweet.IndexedKeyword]!
        switch keyword {
        case .URL:
            keywords = tweet!.urls
        case .HashTag:
            keywords = tweet!.hashtags
        case .UserMentions:
            keywords = tweet!.userMentions
        }
        
        // highlight
        if !keywords.isEmpty {
            if let attributeString = tweetTextLabel.attributedText {
                let mutableAttributedText = NSMutableAttributedString(attributedString: attributeString)
                for indexedKeyword in keywords {
                    let range = indexedKeyword.nsrange
                    mutableAttributedText.addAttributes([NSForegroundColorAttributeName: UIColor.blueColor()], range: range)
                }
                tweetTextLabel.attributedText = mutableAttributedText
            }
        }
    }
    
    private func highlightHashtags() {
        if !tweet!.hashtags.isEmpty {
            if let attributeString = tweetTextLabel.attributedText {
                let mutableAttributedText = NSMutableAttributedString(attributedString: attributeString)
                for indexedKeyword in tweet!.hashtags {
                    let range = indexedKeyword.nsrange
                    mutableAttributedText.addAttributes([NSForegroundColorAttributeName: UIColor.blueColor()], range: range)
                }
                tweetTextLabel.attributedText = mutableAttributedText
            }
        }
    }
    
    private func highlightUrls() {
        if !tweet!.urls.isEmpty {
            if let attributeString = tweetTextLabel.attributedText {
                let mutableAttributedText = NSMutableAttributedString(attributedString: attributeString)
                for indexedKeyword in tweet!.urls {
                    let range = indexedKeyword.nsrange
                    mutableAttributedText.addAttributes([NSLinkAttributeName: indexedKeyword.keyword], range: range)
                }
                tweetTextLabel.attributedText = mutableAttributedText
            }
        }
    }
    
    private func highlightName() {
        if !tweet!.userMentions.isEmpty {
            if let attributeString = tweetTextLabel.attributedText {
                let mutableAttributedText = NSMutableAttributedString(attributedString: attributeString)
                for indexedKeyword in tweet!.userMentions {
                    let range = indexedKeyword.nsrange
                    mutableAttributedText.addAttributes([NSForegroundColorAttributeName: UIColor.blueColor()], range: range)
                }
                tweetTextLabel.attributedText = mutableAttributedText
            }
        }
    }
}
