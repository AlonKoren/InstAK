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
    var followingUsers : [String : BooleanObject] = [:]
    var listen : Listener?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadUsers()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        listen?.disconnected()
        users.removeAll()
        followingUsers.removeAll()
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
            self.isFollowing(user: addedUser) { (isFollowing) in
                self.users.append(addedUser)
                self.followingUsers[addedUser.uid!] = BooleanObject.init(bool: isFollowing)
                self.tableView.reloadData()
            }
            
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
            self.followingUsers.removeValue(forKey: removedUser.uid!)
            self.tableView.reloadData()
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func isFollowing(user: User,onCompletion :@escaping (Bool) -> Void){
        if !AuthService.isSignIn(){
            return
        }
        
        Api.Follow.isFollowingAfterUser(followerUserId: AuthService.getCurrentUserId()!, followingUserId: user.uid!, onCompletion: onCompletion) { (error) in
            print(error.localizedDescription)
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("segue.identifier =\(String(describing: segue.identifier))")
        if segue.identifier == "ProfileSegue"{
            let profileUserViewController = segue.destination as! ProfileUserViewController
            let userId = sender as! String
            profileUserViewController.userId = userId
            print("userId=\(userId)")
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
        cell.isFollowing = self.followingUsers[user.uid!]
        
        cell.delegate = self

        return cell
    }
}


extension PeopleViewController: PeopleTableViewCellDelegate{
    func goToProfileUserViewController(userId: String) {
         self.performSegue(withIdentifier: "ProfileSegue", sender: userId)
    }
}


class BooleanObject {
    var bool : Bool
    
    init(bool : Bool) {
        self.bool = bool
    }
    
    func getBool() -> Bool {
        return self.bool
    }
    func setBool(bool : Bool){
        self.bool = bool
    }
}
