//
//  homeTableViewController.swift
//  Twitter
//
//  Created by Osama Soliman on 2/16/19.
//  Copyright © 2019 Dan. All rights reserved.
//

import UIKit

class homeTableViewController: UITableViewController {
    var tweetArray = [NSDictionary]()
    var noOfTweets: Int!
    let myRefreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 100
        loadTweets()
        myRefreshControl.addTarget(self, action: #selector(loadTweets), for: .valueChanged)
        tableView.refreshControl = myRefreshControl

      
    }
    
    @objc func  loadTweets() {
        noOfTweets = 20
        let tweetsURL = "https://api.twitter.com/1.1/statuses/home_timeline.json"
        let myParams = ["count": noOfTweets]
        TwitterAPICaller.client?.getDictionariesRequest(url: tweetsURL, parameters: myParams as [String : Any], success: { (tweets: [NSDictionary]) in
            self.tweetArray.removeAll()
            for tweet in tweets{
                self.tweetArray.append(tweet)
            }
            self.tableView.reloadData()
            self.myRefreshControl.endRefreshing()
        }, failure: { (Error) in
            print("could not get tweets")
        })
    }
    
    func loadMoreTweets(){
        let tweetsURL = "https://api.twitter.com/1.1/statuses/home_timeline.json"
        noOfTweets = noOfTweets + 20
        let myParams = ["count": noOfTweets]
        TwitterAPICaller.client?.getDictionariesRequest(url: tweetsURL, parameters: myParams as [String : Any], success: { (tweets: [NSDictionary]) in
            self.tweetArray.removeAll()
            for tweet in tweets{
                self.tweetArray.append(tweet)
            }
            self.tableView.reloadData()
        }, failure: { (Error) in
            print("could not get tweets")
        })
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tweetCell", for: indexPath) as! tweetTableViewCell
        let user = tweetArray[indexPath.row]["user"] as! NSDictionary
        cell.tweetContentLabel.text = tweetArray[indexPath.row]["text"] as? String
        cell.userNameLabel.text = user["name"] as? String
        let imageURL = URL(string: (user["profile_image_url_https"] as? String)!)
        let data = try? Data(contentsOf: imageURL!)
        if let imageData = data{
            cell.profileImageView.image = UIImage(data: imageData)
        }
        return cell
    }

    // MARK: - Table view data source
    
    @IBAction func onLogout(_ sender: Any) {
        TwitterAPICaller.client?.logout()
        self.dismiss(animated: true, completion: nil)
        UserDefaults.standard.set(false, forKey: "userLogedin")
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return tweetArray.count
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath ){
        if indexPath.row + 1 == tweetArray.count {
            loadMoreTweets()
        }
    }
  
}
