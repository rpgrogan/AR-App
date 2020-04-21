//
//  StudentTableController.swift
//  ARApp
//
//  Created by Ryan Grogan on 4/21/20.
//  Copyright © 2020 Ryan Grogan. All rights reserved.
//

import SwiftUI

class StudentTableController : UITableViewController{
    
    var students:[User]?
    @IBOutlet var StdntTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return students!.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdnetifier = "StudentCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdnetifier, for: indexPath) as? StudentCell
        let student = students![indexPath.row]
        cell?.Img.image = UIImage(contentsOfFile: student.username)
        cell?.Name.text = student.name
        cell?.Bio.text = student.bio
        return cell!
    }
}
