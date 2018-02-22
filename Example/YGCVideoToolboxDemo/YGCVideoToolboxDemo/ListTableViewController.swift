//
//  ListTableViewController.swift
//  YGCVideoToolboxDemo
//
//  Created by Qilong Zang on 22/02/2018.
//  Copyright © 2018 Qilong Zang. All rights reserved.
//

import UIKit

class ListTableViewController: UITableViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    self.title = "Demo"
   // self.navigationController?.isNavigationBarHidden = true
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = false

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  // MARK: - Table view data source

  override func numberOfSections(in tableView: UITableView) -> Int {
    // #warning Incomplete implementation, return the number of sections
    return 1
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    // #warning Incomplete implementation, return the number of rows
    return 4
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
  }
}
