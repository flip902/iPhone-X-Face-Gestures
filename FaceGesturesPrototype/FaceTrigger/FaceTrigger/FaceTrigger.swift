//
//  FaceTrigger.swift
//  FaceTrigger
//
//  Created by Michael Peterson on 12/26/17.
//  Copyright © 2017 Blinkloop. All rights reserved.
//

import UIKit
import ARKit

@objc public protocol FaceTriggerDelegate: ARSCNViewDelegate {
    
    @objc optional func onSmile()
    @objc optional func onSmileDidChange(smiling: Bool)
    
    @objc optional func onFrown()
    @objc optional func onFrownDidChange(frowning: Bool)
    
    @objc optional func onBlink()
    @objc optional func onBlinkDidChange(blinking: Bool)
    
    @objc optional func onBlinkLeft()
    @objc optional func onBlinkLeftDidChange(blinkingLeft: Bool)
    
    @objc optional func onBlinkRight()
    @objc optional func onBlinkRightDidChange(blinkingRight: Bool)
    
    @objc optional func onCheekPuff()
    @objc optional func onCheekPuffDidChange(cheekPuffing: Bool)
    
    @objc optional func onMouthPucker()
    @objc optional func onMouthPuckerDidChange(mouthPuckering: Bool)
    
    @objc optional func onJawOpen()
    @objc optional func onJawOpenDidChange(jawOpening: Bool)
    
    @objc optional func onJawLeft()
    @objc optional func onJawLeftDidChange(jawLefting: Bool)
    
    @objc optional func onJawRight()
    @objc optional func onJawRightDidChange(jawRighting: Bool)
    
    @objc optional func onBrowDown()
    @objc optional func onBrowDownDidChange(browDown: Bool)
    
    @objc optional func onBrowUp()
    @objc optional func onBrowUpDidChange(browUp: Bool)
    
    @objc optional func onSquint()
    @objc optional func onSquintDidChange(squinting: Bool)
}

public class FaceTrigger: NSObject, ARSCNViewDelegate {
    
    private var sceneView: ARSCNView?
    private let sceneViewSessionOptions: ARSession.RunOptions = [.resetTracking, .removeExistingAnchors]
    private let hostView: UIView
    private let delegate: FaceTriggerDelegate
    private var evaluators = [FaceTriggerEvaluatorProtocol]()
    
    public var smileThreshold: Float = 0.7
    public var frownThreshold: Float = 0.5 //Specific to Shawn's face
    public var blinkThreshold: Float = 0.68 //Specific to Shawn's face
    public var browDownThreshold: Float = 0.7
    public var browUpThreshold: Float = 0.8
    public var cheekPuffThreshold: Float = 0.25 //Specific to Shawn's face
    public var mouthPuckerThreshold: Float = 0.8
    public var jawOpenThreshold: Float = 0.9
    public var jawLeftThreshold: Float = 0.15 //Specific to Shawn's face
    public var jawRightThreshold: Float = 0.02 //Specific to Shawn's face
    public var squintThreshold: Float = 0.8
    
    public var hidePreview: Bool = false //This can deactivate the camera
    
    public init(hostView: UIView, delegate: FaceTriggerDelegate) {
        
        self.hostView = hostView
        self.delegate = delegate
    }
    
    static public var isSupported: Bool {
        return ARFaceTrackingConfiguration.isSupported
    }
    
    public func start() {
        
        guard FaceTrigger.isSupported else {
            NSLog("FaceTrigger is not supported.")
            return
        }
        
        // evaluators
        evaluators.append(SmileEvaluator(threshold: smileThreshold))
        evaluators.append(FrownEvaluator(threshold: frownThreshold))
        evaluators.append(BlinkEvaluator(threshold: blinkThreshold))
        evaluators.append(BrowDownEvaluator(threshold: browDownThreshold))
        evaluators.append(BrowUpEvaluator(threshold: browUpThreshold))
        evaluators.append(CheekPuffEvaluator(threshold: cheekPuffThreshold))
        evaluators.append(MouthPuckerEvaluator(threshold: mouthPuckerThreshold))
        evaluators.append(JawOpenEvaluator(threshold: jawOpenThreshold))
        evaluators.append(JawLeftEvaluator(threshold: jawLeftThreshold))
        evaluators.append(JawRightEvaluator(threshold: jawRightThreshold))
        evaluators.append(SquintEvaluator(threshold: squintThreshold))
        
        // ARSCNView
        let configuration = ARFaceTrackingConfiguration()
        configuration.isLightEstimationEnabled = true
        
        sceneView = ARSCNView(frame: hostView.bounds)
        sceneView!.automaticallyUpdatesLighting = true
        sceneView!.session.run(configuration, options: sceneViewSessionOptions)
        sceneView!.isHidden = hidePreview
        sceneView!.delegate = self
        
        hostView.addSubview(sceneView!)
    }
    
    public func stop() {
        
        pause()
        sceneView?.removeFromSuperview()
    }
    
    public func pause() {
        
        sceneView?.session.pause()
    }
    
    public func unpause() {
        
        if let configuration = sceneView?.session.configuration {
            sceneView?.session.run(configuration, options: sceneViewSessionOptions)
        }
    }
    
    public func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        
        guard let faceAnchor = anchor as? ARFaceAnchor else {
            return
        }
        
        let blendShapes = faceAnchor.blendShapes
        evaluators.forEach {
            $0.evaluate(blendShapes, forDelegate: delegate)
        }
    }
}












