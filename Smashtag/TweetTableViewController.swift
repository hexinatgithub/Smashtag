//
//  TweetTableViewController.swift
//  Smashtag
//
//  Created by CS193p Instructor.
//  Copyright (c) 2015 Stanford University. All rights reserved.
//

import UIKit

extension UITableViewController {
    class SelectedIndexPath {
        var section: Int = 0
        var row: Int = 0
        
        init (section: Int, row: Int) { self.section = section; self.row = row }
    }
}

struct UserDefaults {
    static let History = "History"
}

class TweetTableViewController: UITableViewController, UITextFieldDelegate
{
    // MARK: - Public API

    var tweets = [[Tweet]]()

    var searchText: String? = "#stanford" {
        didSet {
            lastSuccessfulRequest = nil
            searchTextField?.text = searchText
            tweets.removeAll()
            tableView.reloadData() // clear out the table view
            storeSearchHistory()
            refresh()
        }
    }
    
    private func storeSearchHistory() {
        func uniqueElementArray(array: [String], element: String, atIndex: Int) -> [String] {
            var newArray = [String]()
            for i in 0..<array.count {
                let item = array[i]
                if item != element {
                    newArray.append(item)
                }
            }
            newArray.insert(element, atIndex: 0)
            return newArray
        }
        
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {
            if let text = self.searchText {
                if let oldHistory = NSUserDefaults().valueForKey(UserDefaults.History) as? [String] {
                    let newHistory = uniqueElementArray(oldHistory, element: text, atIndex: 0)
                    NSUserDefaults().setObject(newHistory, forKey: UserDefaults.History)
                } else {
                    NSUserDefaults().setObject([text], forKey: UserDefaults.History)
                }
            }
        }
    }
    
    // MARK: - View Controller Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        title = Storyboard.Title
        refresh()
    }
    
    // MARK: - Refreshing

    private var lastSuccessfulRequest: TwitterRequest?

    private var nextRequestToAttempt: TwitterRequest? {
        if lastSuccessfulRequest == nil {
            if searchText != nil {
                return TwitterRequest(search: searchText!, count: 100)
            } else {
                return nil
            }
        } else {
            return lastSuccessfulRequest!.requestForNewer
        }
    }
    
    @IBAction private func refresh(sender: UIRefreshControl?) {
        if let request = nextRequestToAttempt {
            request.fetchTweets { (newTweets) -> Void in
                dispatch_async(dispatch_get_main_queue()) { () -> Void in
                    if newTweets.count > 0 {
                        self.lastSuccessfulRequest = request // oops, forgot this line in lecture
                        self.tweets.insert(newTweets, atIndex: 0)
                        self.tableView.reloadData()
                    }
                    sender?.endRefreshing()
                }
            }
        } else {
            sender?.endRefreshing()
        }
    }
    
    func refresh() {
        refreshControl?.beginRefreshing()
        refresh(refreshControl)
    }
    
    // MARK: - Storyboard Connectivity
    
    @IBOutlet private weak var searchTextField: UITextField! {
        didSet {
            searchTextField.delegate = self
            searchTextField.text = searchText
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == searchTextField {
            textField.resignFirstResponder()
            searchText = textField.text
        }
        return true
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selected = SelectedIndexPath(section: indexPath.section, row: indexPath.row)
        performSegueWithIdentifier(Storyboard.SegueToTweetDetail, sender: selected)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            if identifier == Storyboard.SegueToTweetDetail {
                let tdtvc = segue.destinationViewController as! TweetDetailTableViewController
                let selected = sender as! SelectedIndexPath
                tdtvc.tweet = tweets[selected.section][selected.row]
                tdtvc.presentedVC = self
            }
        }
    }

    
    // MARK: - UITableViewDataSource
    private struct Storyboard {
        static let CellReuseIdentifier = "Tweet"
        static let SegueToTweetDetail = "TweetDetail"
        static let Title = "Tweet"
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return tweets.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets[section].count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.CellReuseIdentifier, forIndexPath: indexPath) as! TweetTableViewCell

        cell.tweet = tweets[indexPath.section][indexPath.row]

        return cell
    }
    
}