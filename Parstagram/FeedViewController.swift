//
//  FeedViewController.swift
//  Parstagram
//
//  Created by Isabel Silva on 3/25/22.
//

import UIKit
import Parse
import AlamofireImage
import MessageInputBar

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MessageInputBarDelegate {

    @IBOutlet weak var tableView: UITableView!
    let commentBar = MessageInputBar()
    var numberofPosts: Int!
    let myRefreshControl = UIRefreshControl()
    var posts = [PFObject]()
    var selectedPost: PFObject!
    var showsCommentBar = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        commentBar.inputTextView.placeholder = "Add a comment..."
        commentBar.sendButton.title = "Post"
        commentBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        myRefreshControl.addTarget(self, action: #selector(loadPosts), for: .valueChanged)
        self.tableView.refreshControl = myRefreshControl
        tableView.keyboardDismissMode = .interactive
        
        let center = NotificationCenter.default
        center.addObserver(self,selector: #selector(keyboardWillBeHidden(note:)), name: UIResponder.keyboardWillHideNotification , object: nil)
        // Do any additional setup after loading the view.
    }
    
    @objc func keyboardWillBeHidden(note: Notification){
        commentBar.inputTextView.text = nil
        showsCommentBar = false
        becomeFirstResponder()
        
    }
    override var inputAccessoryView: UIView? {
        return commentBar
    }
    override var canBecomeFirstResponder: Bool{
        return showsCommentBar
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
        numberofPosts = 20
        let query = PFQuery(className:"Post")
        query.includeKeys(["author","comments","comments.author"])
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
        numberofPosts = numberofPosts+23
        let query = PFQuery(className:"Post")
        query.includeKeys(["author","comments","comments.author"])
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
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        // Create the Comment
        let comment = PFObject(className: "Comments")
        comment["text"] = text
        comment["post"] = selectedPost
        comment["author"] = PFUser.current()!

        selectedPost.add(comment,forKey: "comments")

        selectedPost.saveInBackground{ (success,error) in
            if success{
            print("Comment saved")
            } else{
                print("Error saving comment: \(error)")
            }
        }
        tableView.reloadData()
        // Clear and dismiss the input bar
        commentBar.inputTextView.text = nil
        showsCommentBar = false
        becomeFirstResponder()
        commentBar.inputTextView.resignFirstResponder()
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let post = posts[section]
        let comments = (post["comments"] as? [PFObject]) ?? []
        
        return comments.count + 2
    }
    func numberOfSections(in tableView:UITableView) -> Int{
        return posts.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let post = posts[indexPath.section]
        let comments = (post["comments"] as? [PFObject]) ?? []
                
        if indexPath.row == 0
        {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostsTableViewCell") as! PostsTableViewCell
        

        let user = post["author"] as! PFUser
        cell.usernameLabel.text = user.username
        cell.captionLabel.text = post["caption"] as! String
        
        let imageFile = post["image"] as! PFFileObject
        let urlString = imageFile.url!
        let url = URL(string:urlString)!
        cell.photoView.af_setImage(withURL: url)
        return cell
            
        } else if indexPath.row <= comments.count {
                let cell = tableView.dequeueReusableCell(withIdentifier: "CommentTableViewCell") as! CommentTableViewCell
                let comment = comments[indexPath.row-1]
                cell.commentLabel.text = comment["text"] as? String
                let user = comment["author"] as! PFUser
                cell.nameLabel.text = user.username
                return cell
            } else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "AddCommentCell")!
                return cell
            }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let post = posts[indexPath.section]
        let comments = (post["comments"] as? [PFObject]) ?? []
        
        if indexPath.row == comments.count+1{
            showsCommentBar = true
            becomeFirstResponder()
            commentBar.inputTextView.becomeFirstResponder()
            
            selectedPost = post
        }
    }
    @IBAction func onLogOut(_ sender: Any) {
        PFUser.logOut()
        let main = UIStoryboard(name: "Main", bundle: nil)
        let loginViewController = main.instantiateViewController(withIdentifier: "LoginViewController")
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene, let delegate = windowScene.delegate as? SceneDelegate else {return }
        
        delegate.window?.rootViewController = loginViewController
        
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
