//
//  FeedViewController.swift
//  Parstagram
//
//  Created by Isabel Silva on 3/25/22.
//

import UIKit
import Parse
import AlamofireImage

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var numberofPosts: Int!
    let myRefreshControl = UIRefreshControl()
    var posts = [PFObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        myRefreshControl.addTarget(self, action: #selector(loadPosts), for: .valueChanged)
        self.tableView.refreshControl = myRefreshControl
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
//        query.findObjectsInBackground{(postS, error) in
//            if postS != nil {
//                self.posts = postS!
//                self.tableView.reloadData()
//            }
//        }
        self.loadPosts()
    }
    @objc func loadPosts(){
        numberofPosts = 1
        let query = PFQuery(className:"Post")
        query.includeKey("author")
        query.limit = numberofPosts
        query.findObjectsInBackground{(postS, error) in
            if postS != nil {
                self.posts = postS!
                self.tableView.reloadData()
            }
        }
        myRefreshControl.endRefreshing()

    }
    
    func loadMorePosts(){
        numberofPosts = numberofPosts+2
        let query = PFQuery(className:"Post")
        query.includeKey("author")
        query.limit = numberofPosts
        query.findObjectsInBackground{(postS, error) in
            if postS != nil {
                self.posts = postS!
                self.tableView.reloadData()
            }
        }    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == posts.count{
            loadMorePosts()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PostsTableViewCell") as? PostsTableViewCell
        else {
            return UITableViewCell()
        }
        
        let post = posts[indexPath.row]

        let user = post["author"] as! PFUser
        cell.usernameLabel.text = user.username
        cell.captionLabel.text = post["caption"] as! String
        
        let imageFile = post["image"] as! PFFileObject
        let urlString = imageFile.url!
        let url = URL(string:urlString)!
        cell.photoView.af_setImage(withURL: url)
        return cell
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
