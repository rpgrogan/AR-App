//
//  PlaneNode.swift
//  ARApp
//
//  Created by admin on 4/27/20.
//  Copyright © 2020 GIMM. All rights reserved.
//

import ARKit
import SceneKit

public class PlaneNode: SCNNode {
    
    public func update(from planeAnchor: ARPlaneAnchor) {
        //need a new geometry each time fro the use of physics updates if we dont need and physics we can probably remove this
        guard let device = MTLCreateSystemDefaultDevice(), let geom = ARSCNPlaneGeometry(device: device) else {
            fatalError()
        }
        
        //this allows the material to be invisible but still recieve shadows and hide objects behind them
        let material = SCNMaterial()
        material.lightingModel = .constant
        material.writesToDepthBuffer = true
        material.colorBufferWriteMask = []
        geom.firstMaterial = material
        
        geom.update(from: planeAnchor.geometry)
        
        //We modify our plane geometry each time ARkit updates our existing plane
        geometry = geom
        
        castsShadow = false
        
        //We need to declare the bounding box or it will not work
        let shape = SCNPhysicsShape(geometry: geom, options: [SCNPhysicsShape.Option.type: SCNPhysicsShape.ShapeType.boundingBox, SCNPhysicsShape.Option.collisionMargin : 0.0])
        
        physicsBody = SCNPhysicsBody(type: .static, shape: shape)
        
        scale = SCNVector3(0.9,1.0,0.9)
    }
}
