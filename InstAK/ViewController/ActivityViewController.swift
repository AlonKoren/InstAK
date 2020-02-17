//
//  ActivityViewController.swift
//  InstAK
//
//  Created by alon koren on 21/12/2019.
//  Copyright © 2019 Alon Koren. All rights reserved.
//

import UIKit

class ActivityViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var notifications : [Notification] = []
    var users = [String: User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadNotifications()
    }
    
    func loadNotifications(){
        ProgressHUD.show("Loading...", interaction: false)
        self.users.removeAll()
        self.notifications.removeAll()
        self.tableView.reloadData()
        guard let currentUserId = AuthService.getCurrentUserId() else {
            return
        }
        Api.Notifiaction.getNotifications(userId: currentUserId, onCompletion: { (notifications) in
            self.users.removeAll()
            self.notifications.removeAll()
            self.tableView.reloadData()

            notifications.forEach { (notification) in
                self.fechUser(userId: notification.fromId!) { (user) in
                    self.notifications.insert(notification, at: 0)
                    self.users[notification.notificationId!] = user
                    self.notifications.sort { (aNotification, bNotification) -> Bool in
                        return aNotification.timestamp ?? 0 > bNotification.timestamp ?? 0
                    }
                    self.tableView.reloadData()
                }
            }
            ProgressHUD.dismiss()

        }) { (error) in
            self.users.removeAll()
            self.notifications.removeAll()
            self.tableView.reloadData()
            print(error.localizedDescription)
        }
    }
    
    func fechUser(userId: String , onCompletion: @escaping (User)-> Void){
        Api.User.getUser(withId: userId, onCompletion: onCompletion) { (error) in
            print(error.localizedDescription)
        }
    }
    
    
    @IBAction func refresh_TouchUpInside(_ sender: Any) {
        loadNotifications()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("segue.identifier =\(String(describing: segue.identifier))")
        if segue.identifier == "Activity_DetailSegue"{
            let detailViewController = segue.destination as! DetailViewController
            let postId = sender as! String
            detailViewController.postId = postId
        }
        if segue.identifier == "Activity_ProfileSegue" {
            let profileVC = segue.destination as! ProfileUserViewController
            let userId = sender  as! String
            profileVC.userId = userId
        }
        
        if segue.identifier == "Activity_CommentSegue" {
            let commentVC = segue.destination as! CommentViewController
            let postId = sender  as! String
            commentVC.postId = postId
        }
    }
}

extension ActivityViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ActivityTableViewCell", for: indexPath) as! ActivityTableViewCell
        let notification = notifications[indexPath.item]
        cell.user = self.users[notification.notificationId!]!
        cell.notification = notification
        cell.delegate = self
        return cell
    }
}
extension ActivityViewController: ActivityTableViewCellDelegate{
    
    func goToDetailViewController(postId: String) {
        performSegue(withIdentifier: "Activity_DetailSegue", sender: postId)
    }
    
    func goToProfileViewController(userId: String) {
        performSegue(withIdentifier: "Activity_ProfileSegue", sender: userId)
    }
    
    func goToCommentViewController(postId: String) {
        performSegue(withIdentifier: "Activity_CommentSegue", sender: postId)
    }
    
    
}
