//
//  StudentCell.swift
//  ARApp
//
//  Created by Ryan Grogan on 4/21/20.
//  Copyright © 2020 Ryan Grogan. All rights reserved.
//

import SwiftUI

class StudentCell: UITableViewCell {
    var student:User!
    @IBOutlet weak var Img: UIImageView!
    @IBOutlet weak var Name: UILabel!
    @IBOutlet weak var Age: UILabel!
    @IBOutlet weak var Bio: UILabel!
}
