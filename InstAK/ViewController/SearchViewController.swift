//
//  SearchViewController.swift
//  InstAK
//
//  Created by alon koren on 14/01/2020.
//  Copyright © 2020 Alon Koren. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {

    var searchBar = UISearchBar()
    @IBOutlet weak var tableView: UITableView!
    var users = [User]()
    var followingUsers : [String : BooleanObject] = [:]
    var listener : Listener?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
        searchBar.searchBarStyle = .minimal
        searchBar.placeholder = "Search"
        searchBar.frame.size.width = view.frame.size.width - 60
        
        let searchItem = UIBarButtonItem(customView: searchBar)
        self.navigationItem.rightBarButtonItem = searchItem
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        doSearch()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        listener?.disconnected()
    }
    
    func doSearch(){
        if let searchText = searchBar.text{
            self.users.removeAll()
            self.followingUsers.removeAll()
            self.tableView.reloadData()
            listener?.disconnected()
            listener = Api.User.queryUsers(withText: searchText.lowercased(), onAdded: { (addedUser) in
                
                self.isFollowing(user: addedUser) { (isFollowing) in
                    self.users.append(addedUser)
                    self.followingUsers[addedUser.uid!] = BooleanObject.init(bool: isFollowing)
                    self.tableView.reloadData()
                }
                
            }, onModified: { (modifiedUser) in
                
                self.users.forEach { (user) in
                    if user.uid == modifiedUser.uid{
                        user.setData(user: modifiedUser)
                    }
                }
                self.tableView.reloadData()
            }, onRemoved: { (removedUser) in
                
                self.users.removeAll { (user) -> Bool in
                    return user.uid == removedUser.uid
                }
                self.followingUsers.removeValue(forKey: removedUser.uid!)
                self.tableView.reloadData()
            }) { (error) in
                print(error.localizedDescription)
            }
            
            
        }else{
            self.users.removeAll()
            self.followingUsers.removeAll()
            self.tableView.reloadData()
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
    
    
}

extension SearchViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("searchBarSearchButtonClicked")
        doSearch()
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print("textDidChange")
        doSearch()
    }
}
extension SearchViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PeopleTableViewCell", for: indexPath) as! PeopleTableViewCell
        let user = users[indexPath.row]
        cell.user = user
        cell.isFollowing = self.followingUsers[user.uid!]
        

        return cell
    }
}
