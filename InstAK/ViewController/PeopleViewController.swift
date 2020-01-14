//
//  PeopleViewController.swift
//  InstAK
//
//  Created by alon koren on 14/01/2020.
//  Copyright © 2020 Alon Koren. All rights reserved.
//

import UIKit

class PeopleViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var users = [User]()
    var listen : Listener?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        loadUsers()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        listen?.disconnected()
    }
    
    
    func loadUsers()  {
        if !AuthService.isSignIn(){
            return
        }
        
        let currentUserId = AuthService.getCurrentUserId()
        
        listen = Api.User.observeAllUsers(onAdded: { (addedUser) in
            if currentUserId == addedUser.uid {
                return
            }
            self.users.append(addedUser)
            self.tableView.reloadData()
        }, onModified: { (modifiedUser) in
            if currentUserId == modifiedUser.uid {
                return
            }
            self.users.forEach { (user) in
                if user.uid == modifiedUser.uid{
                    user.setData(user: modifiedUser)
                }
            }
            self.tableView.reloadData()
        }, onRemoved: { (removedUser) in
            if currentUserId == removedUser.uid {
                return
            }
            self.users.removeAll { (user) -> Bool in
                return user.uid == removedUser.uid
            }
            self.tableView.reloadData()
        }) { (error) in
            
        }
    }

}

extension PeopleViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PeopleTableViewCell", for: indexPath) as! PeopleTableViewCell
        let user = users[indexPath.row]
        cell.user = user
        return cell
    }
}
