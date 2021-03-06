//
//  StudentTableController.swift
//  ARApp
//
//  Created by Ryan Grogan on 4/21/20.
//  Copyright © 2020 Ryan Grogan. All rights reserved.
//

import SwiftUI

protocol SetStudentDelegate{
    func SetStudent(studnt: User, view: StudentTableController)
}

class StudentTableController : UITableViewController{
    var delegate: SetStudentDelegate?
    var user:User!
    var students:[User]!
    var selectedStdnt:User?
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
        cell?.student = student
        cell?.Img.image = UIImage(named: student.username)
        cell?.Name.text = student.name
        cell?.Age.text = String(student.age)
        cell?.Bio.text = student.bio
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Index Path: \(indexPath.row)")
        selectedStdnt = students[indexPath.row]
        delegate!.SetStudent(studnt: selectedStdnt!, view: self)
    }
}
