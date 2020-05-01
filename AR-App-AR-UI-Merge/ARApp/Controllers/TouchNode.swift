//
//  TouchNode.swift
//  ARApp
//
//  Created by admin on 4/27/20.
//  Copyright © 2020 GIMM. All rights reserved.
//

import SceneKit

public class TouchNode: SCNNode {
    
    public override init() {
        super.init()
        commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        //Touch node config if we want multiple touch nodes or different shapes this is where we will need to change it
        let sphere = SCNSphere(radius: 0.01)
        
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red
        
        //Uncomment the below line to see the sphere for debugging
        //geometry = sphere
        sphere.firstMaterial = material
        
        let sphereShape = SCNPhysicsShape(geometry: sphere, options: nil)
        
        physicsBody = SCNPhysicsBody(type: .kinematic, shape: sphereShape)
    }
}
