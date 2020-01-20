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
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension ActivityViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ActivityTableViewCell", for: indexPath) as! ActivityTableViewCell
        cell.nameLabel.text = "Alon"
        cell.profileImage.image = #imageLiteral(resourceName: "placeholder-avatar-profile")
        return cell
    }
}
