//
//  ViewController.swift
//  Workspace
//
//  Created by James touri and Alexander Dimopoulos on 9/9/19.
//  Copyright © 2019 jamestouri & alexanderdimopoulos. All rights reserved.
//

import UIKit
import ARKit
import WebKit
import SpriteKit

// Where the logic will be. There are 2 buttons. To add choose how many screens they want. They can increment and decrement
class ARViewController: UIViewController, UIWebViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var numberOfScreens: UILabel!
    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var uiImplementView: UIView!
    
    var counter = 1
    var alreadyClicked = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.numberOfScreens.text = "1"
        urlTextField.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let configeration = ARWorldTrackingConfiguration()
        sceneView.session.run(configeration)
        uiImplementView.isHidden = true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {return}
        let result = sceneView.hitTest(touch.location(in: sceneView), types: [ARHitTestResult.ResultType.featurePoint])
        guard let hitResult = result.last else {return}
        let hitTransform = SCNMatrix4.init(hitResult.worldTransform)
        let hitVector = SCNVector3Make(hitTransform.m41, hitTransform.m42, hitTransform.m43)
        createScreen(position: hitVector)
    }
    
    func createScreen(position: SCNVector3) {
        DispatchQueue.main.async {
            let rect = CGRect(x: 40, y: 80, width: 400, height: 400)
            let webView: UIWebView! = UIWebView(frame: rect)
            self.view.addSubview(webView!)
            let displayPlane = SCNPlane(width: 0.5,height: 0.3)
            let webUrl : NSURL = NSURL(string: "https://www.reddit.com/")!
            let request : NSURLRequest = NSURLRequest(url: webUrl as URL)
            webView.loadRequest(request as URLRequest)
            displayPlane.firstMaterial?.diffuse.contents = webView
            let webScreen = SCNNode(geometry: displayPlane)
            webScreen.position = position
            self.sceneView.scene.rootNode.addChildNode(webScreen)
        }
    }
 
    @IBAction func decrementButton(_ sender: Any) {
        if counter >= 2 {
            counter -= 1
            self.numberOfScreens.text = String(counter)
        }
    }
        
    @IBAction func incrementButton(_ sender: Any) {
        if counter <= 5 {
            counter += 1
            self.numberOfScreens.text = String(counter)
        }
        // Former action is now in uiImplementView for users to fill out their url
        uiImplementView.isHidden = false
    }
    
    @IBAction func createARView(_ sender: Any) {
        // Put action in separate method for same action with return button too
        forButtonClick()
        alreadyClicked = false
    }
    
    @IBAction func getRidOfView(_ sender: Any) {
        uiImplementView.isHidden = true
    }
    
//    call this function to get current location * other transformation code
    func getCameraCoordinates(sceneView: ARSCNView) -> myCameraCoordinates {
        let cameraTransform = sceneView.session.currentFrame?.camera.transform
        let cameraCoordinates = MDLTransform(matrix: cameraTransform!)
        var cc = myCameraCoordinates()
        cc.x = cameraCoordinates.translation.x
        cc.y = cameraCoordinates.translation.y
        cc.z = cameraCoordinates.translation.z
        return cc
    }

//    variables with view location data
    struct myCameraCoordinates {
        var x = Float()
        var y = Float()
        var z = Float()
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if !alreadyClicked {
            forButtonClick()
        }
        return true;
    }
    
    private func forButtonClick() {
        uiImplementView.isHidden = true
        DispatchQueue.main.async {
            let rect = CGRect(x: 40, y: 80, width: 400, height: 400)
            let webView: UIWebView! = UIWebView(frame: rect)
            self.view.addSubview(webView!)
            let displayPlane = SCNPlane(width: 0.5,height: 0.3)
            let givenUrl = "https://" + (self.urlTextField.text ?? "google.com")
            let webUrl : NSURL = NSURL(string: givenUrl)!
            let request : NSURLRequest = NSURLRequest(url: webUrl as URL)
            webView.loadRequest(request as URLRequest)
            displayPlane.firstMaterial?.diffuse.contents = webView
            let webScreen = SCNNode(geometry: displayPlane)
            let cc = self.getCameraCoordinates(sceneView: self.sceneView)
            webScreen.position = SCNVector3(cc.x, cc.y, cc.z - 0.75)
            self.sceneView.scene.rootNode.addChildNode(webScreen)
        }
    }
}
