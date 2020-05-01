//
//  ARController.swift
//  ARApp
//
//  Created by Ryan Grogan on 3/14/20.
//  Copyright © 2020 Ryan Grogan. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import Vision
import CoreML

enum GameState: Int16 {
    case surfaceDetection
    case sinkSetup
    case handwashingDemo
    case handwashing
}

class ARController: UIViewController, ARSCNViewDelegate, ARSessionDelegate {

    var statusText: String = ""
    var tracking: String = ""
    
    //variables for the hand detection
    var currentBuffer: CVPixelBuffer?
    var previewView = UIImageView()
    let touchNode = TouchNode()
    //this will be the node we use to allow interactions with the soap dispensor we will need a node for everything we will interact with
    let soap = SoapNode(radius: 0.05)
    
    var gameState: GameState = .surfaceDetection
    var focusPoint:CGPoint!
    var wallNode: SCNNode!
    var focusNode: SCNNode!

    //Models
    //var soapBottleNode: SCNNode!
    //var sinkNode: SCNNode!
    @IBOutlet var sceneView: ARView!
    @IBOutlet weak var statusLabel: UILabel!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //Sets up session config for testing on device in real time
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        sceneView.autoenablesDefaultLighting = true
        
        //Implementation of the CoreML for hand recognition
        //this checks the frames on the video through the delegate allowing for smoother hand tracking
        sceneView.session.delegate = self
        
        sceneView.session.run(configuration)
        
        sceneView.delegate = self
        
        sceneView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewDidTap(recognizer:))))
        
        //spotlight to cast shadows if we want to try this not needed
        let spotlightNode = SpotlightNode()
        spotlightNode.position = SCNVector3(10, 10, 0)
        sceneView.scene.rootNode.addChildNode(spotlightNode)
        
        //add touchNode
        sceneView.scene.rootNode.addChildNode(touchNode)
        
        initSceneView()
        initScene()
        initARSession()

        statusLabel.text = "View loaded"
    }
    
    @objc private func viewDidTap(recognizer: UITapGestureRecognizer) {
        
        //recycle the soap nodes and all other touchable object nodes
        soap.removeFromParentNode()
        soap.physicsBody?.clearAllForces()
        
        //obtain the tap location as a 2D screen coordinate
        let tapLocation = recognizer.location(in: sceneView)
        
        //Transform our 2D screen coordinates to 3D screen coordinates use the hitTest
        let hitTestResults = sceneView.hitTest(tapLocation, types: .existingPlaneUsingExtent)
        
        //cast a ray from where we point on the creen and we return any intersection with existing planes
        guard let hitTestResult = hitTestResults.first else { return }
        
        //place the soap and sink at this point
        soap.simdTransform = hitTestResult.worldTransform
        //place it slightly above the plane this is 20cm
        soap.position.y += 0.20
        
        //add the node to the scene --> compiler error when using Simulator
        //sceneView.rootNode.addChildNode(soap)
    }
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        //analyze the frames here and return only is currentBuffer is not nil or if tracking is not normal
        guard currentBuffer == nil, case .normal = frame.camera.trackingState else {
            return
        }
        
        //retain image buffer
        currentBuffer = frame.capturedImage
        
        startDetection()
    }
    
    let handDetector = HandDetector()
    
    private func startDetection() {
        //To avoid force unwrap in VNImageRequestHandler
        guard let buffer = currentBuffer else { return }
        
        handDetector.performDetection(inputBuffer: buffer) { outputBuffer, _ in
            //Here we are on a background thread to run point recognition and images
            var previewImage: UIImage?
            var normalizedFingerTip: CGPoint?
            
            defer {
                DispatchQueue.main.async {
                    self.previewView.image = previewImage
                    
                    //Release currentBuffer when finished to allow processing next frame
                    self.currentBuffer = nil
                    //this sets the touch node to be hidden so the user wont see it
                    self.touchNode.isHidden = true
                    
                    guard let tipPoint = normalizedFingerTip else {
                        return
                    }
                    
                    //We use coreVideo function to get image coordinate
                    let imageFingerPoint = VNImagePointForNormalizedPoint(tipPoint, Int(self.view.bounds.size.width), Int(self.view.bounds.size.height))
                    
                    //hit test translation from 2D coordinates to 3D coordinates
                    let hitTestResults = self.sceneView.hitTest(imageFingerPoint, types: .existingPlaneUsingExtent)
                    guard let hitTestResult = hitTestResults.first else { return }
                    
                    //Position our touchNode slightly above the plane (1cm) we can change this if for some reason it doesnt work the way we want
                    self.touchNode.simdTransform = hitTestResult.worldTransform
                    self.touchNode.position.y += 0.01
                    self.touchNode.isHidden = false
                }
            }
            //checking the buffer once again before continueing
            guard let outBuffer = outputBuffer else {
                return
            }
            
            //Create UIImage from the CVPixelBuffer from earlier
            previewImage = UIImage(ciImage: CIImage(cvPixelBuffer: outBuffer))
            //sets the finger tip to what the coreML finds for the fingertip
            normalizedFingerTip = outBuffer.searchTopPoint()
        }
    }
    
    public func renderer(_: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        guard let _ = anchor as? ARPlaneAnchor else { return nil }
        
        return PlaneNode()
    }
    
    public func renderer(_: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        //guard let planeAnchor = anchor as? ARPlaneAnchor, let planeNode = node as? PlaneNode else { return }
        //planeNode.update(from: planeAnchor)
        
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        DispatchQueue.main.async {

          let planeNode = self.createARPlaneNode(planeAnchor: planeAnchor, color: UIColor.yellow.withAlphaComponent(0.5))
          node.addChildNode(planeNode)
        }
    }
    
    public func renderer(_: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        //guard let planeAnchor = anchor as? ARPlaneAnchor, let planeNode = node as? PlaneNode else { return }
        //planeNode.update(from: planeAnchor)
        
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        DispatchQueue.main.async {
          self.updateARPlaneNode(
            planeNode: node.childNodes[0],
            planeAchor: planeAnchor)
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer,
                  updateAtTime time: TimeInterval) {
      DispatchQueue.main.async {
        self.statusLabel.text = self.statusText
      }
    }

    func session(_ session: ARSession,
                 cameraDidChangeTrackingState camera: ARCamera) {
      switch camera.trackingState {
      case .notAvailable:
        statusText = "Tacking Unavailable"
        break
      case .normal:
        statusText = "Tracking..."
        break
      case .limited(let reason):
        switch reason {
        case .excessiveMotion:
          statusText = "Too much motion"
        case .insufficientFeatures:
          statusText = "Tracking Limited"
        case .initializing:
          statusText = "Initializing..."
        case .relocalizing:
          statusText = "Relocalizing..."
        @unknown default:
          statusText = "Unknown"
          }
      }
    }

    func session(_ session: ARSession,
                 didFailWithError error: Error) {
      statusText = "Session Fail: \(error)"
    }

    func sessionWasInterrupted(_ session: ARSession) {
      statusText = "Session stopped"
    }

    func sessionInterruptionEnded(_ session: ARSession) {
      statusText = "Continuing"
    }

      //func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        //guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        //DispatchQueue.main.async {

          //let planeNode = self.createARPlaneNode(planeAnchor: planeAnchor, color: UIColor.yellow.withAlphaComponent(0.5))
          //node.addChildNode(planeNode)
        //}
      //}

      //func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        //guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        //DispatchQueue.main.async {
          //self.updateARPlaneNode(
            //planeNode: node.childNodes[0],
            //planeAchor: planeAnchor)
        //}
      //}
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()

        sceneView.session.run(configuration)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // Pause the view's session
        sceneView.session.pause()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @objc
    func orientationChanged() {
      focusPoint = CGPoint(x: view.center.x, y: view.center.y + view.center.y * 0.25)
    }

    func initSceneView() {
      sceneView.delegate = self
      sceneView.showsStatistics = true

        focusPoint = CGPoint(x: view.center.x, y: view.center.y + view.center.y * 0.25)
        NotificationCenter.default.addObserver(self, selector: #selector(ARController.orientationChanged), name: UIDevice.orientationDidChangeNotification, object: nil)    }

    func initScene() {
      let scene = SCNScene()
      scene.isPaused = true
      //sceneView.scene = scene

        //scene.lightingEnvironment.contents = ""
        //scene.lightingEnvironment.intensity = 1
    }

    func initARSession() {
        guard ARWorldTrackingConfiguration.isSupported else {
          print("Warning: World Tracking Not Supported")
          return
        }

        let config = ARWorldTrackingConfiguration()
        config.worldAlignment = .gravity
        config.providesAudioData = false
        config.planeDetection = .horizontal
        sceneView.session.run(config)
      }

    func loadModels() {
      let soapBottleScene = SoapNode()
        //soapBottleScene.position = planeNode.position
        
    }
    func updateStatus() {
      switch gameState {
      case .surfaceDetection:
        statusText = "Scan Wall surface"
      case .sinkSetup:
        statusText = "Direct at wall surface"
      case .handwashingDemo:
        statusText = "Demo Playing"
      case .handwashing:
        statusText = "Washing hands now"
        }
      self.statusLabel.text = statusText != "" ?
        "\(tracking)" : "\(statusText)"
    }

    func createARPlaneNode(planeAnchor: ARPlaneAnchor, color: UIColor) -> SCNNode {

      let planeGeometry = SCNPlane(width: CGFloat(planeAnchor.extent.x),
                                   height: CGFloat(planeAnchor.extent.z))
      //Needs Material
      let planeMaterial = SCNMaterial()
      planeGeometry.materials = [planeMaterial]

      let planeNode = SCNNode(geometry: planeGeometry)
      planeNode.position = SCNVector3Make(planeAnchor.center.x, 0, planeAnchor.center.z)
      planeNode.transform = SCNMatrix4MakeRotation(-Float.pi / 2, 1, 0, 0)

      return planeNode
    }

    func updateARPlaneNode(planeNode: SCNNode, planeAchor: ARPlaneAnchor) {

      let planeGeometry = planeNode.geometry as! SCNPlane
      planeGeometry.width = CGFloat(planeAchor.extent.x)
      planeGeometry.height = CGFloat(planeAchor.extent.z)

      planeNode.position = SCNVector3Make(planeAchor.center.x, 0, planeAchor.center.z)
    }

}
