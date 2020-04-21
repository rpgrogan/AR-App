//
//  ARController.swift
//  ARApp
//
//  Created by Ryan Grogan on 3/14/20.
//  Copyright © 2020 Ryan Grogan. All rights reserved.
//

import UIKit

class ARController : UIViewController{
    
    
    @IBOutlet weak var scene: ARScene!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("ARScene Loaded")
    }
    
}
