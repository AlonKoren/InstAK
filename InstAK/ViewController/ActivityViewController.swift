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
        loadNotifications()
    }
    func loadNotifications(){
        guard let currentUserId = AuthService.getCurrentUserId() else {
            return
        }
        Api.Notifiaction.getNotifications(userId: currentUserId, onCompletion: { (notifications) in
            self.notifications.removeAll()
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
            
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func fechUser(userId: String , onCompletion: @escaping (User)-> Void){
        Api.User.getUser(withId: userId, onCompletion: onCompletion) { (error) in
            print(error.localizedDescription)
        }
    }
}

extension ActivityViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ActivityTableViewCell", for: indexPath) as! ActivityTableViewCell
        cell.user = self.users[notifications[indexPath.item].notificationId!]!
        cell.notification = self.notifications[indexPath.item]
        return cell
    }
}
