//
//  ShowImageVideoVC.swift
//  VideoRecorderTest
//
//  Created by Amrit on 9/22/16.
//  Copyright © 2016 Amrit. All rights reserved.
//

import UIKit

class ShowImageVideoVC: UIViewController, UITableViewDataSource {

    var totalImage = [UIImage]()
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return totalImage.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell")
        cell?.imageView?.image = totalImage[indexPath.row]
        return cell!
    }
    
    @IBAction func backAction(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}
