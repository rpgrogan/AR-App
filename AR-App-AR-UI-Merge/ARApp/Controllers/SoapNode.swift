//
//  SoapNode.swift
//  ARApp
//
//  Created by admin on 4/27/20.
//  Copyright © 2020 GIMM. All rights reserved.
//

import SceneKit

public class SoapNode: SCNNode {
    
    public convenience init(radius: CGFloat) {
        self.init()
        //This is where we would connect the 3D and 2D models to the AR enviroment we simply give it a node if it is something we will be interacting with for example the soap bottle would be connected into the code within this node.
        
        var soapBottleNode: SCNNode!
        var sinkNode: SCNNode!
        //var bubbleNode: SCNNode!
        //var germNode: SCNNode!
        
        let handWashingScene = SCNScene(named: "SoapNSink.scnassets/Handwashing.scn")!
        
        soapBottleNode = handWashingScene.rootNode.childNode(withName: "Soap", recursively: true)
        sinkNode = handWashingScene.rootNode.childNode(withName: "Sink", recursively: true)
        //bubbleNode = handWashingScene.rootNode.childNode(withName: "Bubble", recursively: true)
        //germNode = handWashingScene.rootNode.childNode(withName: "Germ", recursively: true)
        
    }
}
