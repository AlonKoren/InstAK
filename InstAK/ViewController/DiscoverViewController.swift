//
//  DiscoverViewController.swift
//  InstAK
//
//  Created by alon koren on 21/12/2019.
//  Copyright © 2019 Alon Koren. All rights reserved.
//

import UIKit

class DiscoverViewController: UIViewController {

    
    @IBOutlet weak var collectionView: UICollectionView!
    var posts = [Post]()
    var postsListener:NSObjectProtocol?
    
    var listener : Listener?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        loadTopPosts()
    }
    
    
    deinit {
        listener?.disconnected()
    }
    override func viewDidDisappear(_ animated: Bool) {
        if let postsListener = self.postsListener{
            ModelNotification.PostListNotification.remove(observer: postsListener)
        }
    }

    
    @IBAction func refresh_TouchUpInside(_ sender: Any) {
        loadTopPosts()
    }
    
    func loadTopPosts(){
        ProgressHUD.show("Loading...", interaction: false)
        self.posts.removeAll()
        self.collectionView.reloadData()
        
        
        
        listener = Model.instance.getAllPosts()
        postsListener = ModelNotification.PostListNotification.observe {
            (data:Any) in
            print("data get")
            let myPosts = data as! [Post]
            self.posts.removeAll()
            self.posts.append(contentsOf: myPosts)
            self.collectionView.reloadData()
            ProgressHUD.dismiss()
        }
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("segue.identifier =\(String(describing: segue.identifier))")
        if segue.identifier == "Discover_DetailSegue"{
            let detailViewController = segue.destination as! DetailViewController
            let postId = sender as! String
            detailViewController.postId = postId
            print("postId=\(postId)")
        }
    }

}


extension DiscoverViewController:UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DiscoverCollectionViewCell", for: indexPath) as! PhotoCollectionViewCell
        let post = posts[indexPath.row]
        cell.post = post
        cell.delegate = self
        return cell
    }
    
}

extension DiscoverViewController: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        return CGSize(width: collectionView.bounds.size.width / 3 - 1 , height: collectionView.bounds.size.width / 3 - 1 )
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

extension DiscoverViewController: PhotoCollectionViewCellDelegate{
    func goToDetailViewController(postId: String) {
        self.performSegue(withIdentifier: "Discover_DetailSegue", sender: postId)
    }
}
