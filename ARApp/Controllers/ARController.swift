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

enum GameState: Int16 {
    case surfaceDetection
    case sinkSetup
    case handwashingDemo
    case handwashing
}

class ViewController: UIViewController {

    var statusText: String = ""
    var tracking: String = ""

    var gameState: GameState = .surfaceDetection
    var focusPoint:CGPoint!
    var wallNode: SCNNode!
    var focusNode: SCNNode!

    //Models
    //var soapBottleNode: SCNNode!
    //var sinkNode: SCNNode!
    
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var statusLabel: UILabel!


    override func viewDidLoad() {
        super.viewDidLoad()

        initSceneView()
        initScene()
        initARSession()

        statusLabel.text = "View loaded"
    }

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
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.orientationChanged), name: UIDevice.orientationDidChangeNotification, object: nil)    }

    func initScene() {
      let scene = SCNScene(named: "Scenes.scnassets/HandwashingDemo.scn")!
      scene.isPaused = false
      sceneView.scene = scene

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
      let soapBottleScene = SCNScene(
        named: "Scenes.scnassets/Models/SoapDispenser.scn")!
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

extension ViewController : ARSCNViewDelegate {

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

    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
      guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
      DispatchQueue.main.async {

        let planeNode = self.createARPlaneNode(planeAnchor: planeAnchor, color: UIColor.yellow.withAlphaComponent(0.5))
        node.addChildNode(planeNode)
      }
    }

    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
      guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
      DispatchQueue.main.async {
        self.updateARPlaneNode(
          planeNode: node.childNodes[0],
          planeAchor: planeAnchor)
      }
    }
}
