//
//  SpotlightNode.swift
//  ARApp
//
//  Created by admin on 4/27/20.
//  Copyright © 2020 GIMM. All rights reserved.
//

import SceneKit

public class SpotlightNode: SCNNode {
    
    public override init() {
        super.init()
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        let spotLight = SCNLight()
        //used to cast shadows if we want that
        spotLight.type = .directional
        spotLight.shadowMode = .deferred
        spotLight.castsShadow = true
        spotLight.shadowRadius = 100.0
        spotLight.shadowColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.2)
        
        light = spotLight
        //this tells the light to point towards the ground
        eulerAngles = SCNVector3(-Float.pi / 2, 0, 0)
    }
}
