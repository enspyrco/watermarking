/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A view controller that recognizes and tracks images found in the user's environment.
*/

import ARKit
import Foundation
import SceneKit
import UIKit

class DetectionViewController: UIViewController {

    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var detectedImage: UIImageView!

    static var instance: DetectionViewController?
    
    var averagedImage: CIImage? = nil
    let filter: CIFilter = CIFilter(name: "WeightedCombine")!
    
    /// An object that detects rectangular shapes in the user's environment.
    let rectangleDetector = RectangleDetector()
    
    /// An object that represents an augmented image that exists in the user's environment.
    var alteredImage: AlteredImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        rectangleDetector.delegate = self
        sceneView.delegate = self
    }

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
        DetectionViewController.instance = self
		
		// Prevent the screen from being dimmed after a while.
		UIApplication.shared.isIdleTimerDisabled = true
        
        searchForNewImageToTrack()
	}
    
    func searchForNewImageToTrack() {
        alteredImage?.delegate = nil
        alteredImage = nil
        
        // Restart the session and remove any image anchors that may have been detected previously.
        runImageTrackingSession(with: [], runOptions: [.removeExistingAnchors, .resetTracking])
        
    }
    
    /// - Tag: ImageTrackingSession
    private func runImageTrackingSession(with trackingImages: Set<ARReferenceImage>,
                                         runOptions: ARSession.RunOptions = [.removeExistingAnchors]) {
        let configuration = ARImageTrackingConfiguration()
        configuration.maximumNumberOfTrackedImages = 1
        configuration.trackingImages = trackingImages
        sceneView.session.run(configuration, options: runOptions)
    }
    
    /// Handles tap gesture input.
    @IBAction func didTap(_ sender: Any) {
        alteredImage?.pauseOrResumeFade()
    }
}

extension DetectionViewController: ARSCNViewDelegate {
    
    /// - Tag: ImageWasRecognized
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        alteredImage?.add(anchor, node: node)
    }

    /// - Tag: DidUpdateAnchor
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        alteredImage?.update(anchor)
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        guard let arError = error as? ARError else { return }
        
        if arError.code == .invalidReferenceImage {
            // Restart the experience, as otherwise the AR session remains stopped.
            // There's no benefit in surfacing this error to the user.
            print("Error: The detected rectangle cannot be tracked.")
            searchForNewImageToTrack()
            return
        }
        
        let errorWithInfo = arError as NSError
        let messages = [
            errorWithInfo.localizedDescription,
            errorWithInfo.localizedFailureReason,
            errorWithInfo.localizedRecoverySuggestion
        ]
        
        // Use `compactMap(_:)` to remove optional error messages.
        let errorMessage = messages.compactMap({ $0 }).joined(separator: "\n")
        
        DispatchQueue.main.async {
            
            // Present an alert informing about the error that just occurred.
            let alertController = UIAlertController(title: "The AR session failed.", message: errorMessage, preferredStyle: .alert)
            let restartAction = UIAlertAction(title: "Restart Session", style: .default) { _ in
                alertController.dismiss(animated: true, completion: nil)
                self.searchForNewImageToTrack()
            }
            alertController.addAction(restartAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
}

extension DetectionViewController: RectangleDetectorDelegate {
    /// Called when the app recognized a rectangular shape in the user's environment.
    /// - Tag: NewAlteredImage
    func rectangleFound(rectangleContent: CIImage) {
        if self.averagedImage == nil {
            self.averagedImage = rectangleContent.copy() as? CIImage
        }
        self.filter.setValue(rectangleContent, forKey: kCIInputImageKey)
        self.filter.setValue(self.averagedImage, forKey: kCIInputBackgroundImageKey)
        
        self.averagedImage = self.filter.outputImage!
        
        DispatchQueue.main.async {
            self.detectedImage.image = UIImage.init(ciImage: self.averagedImage!)
        }
        
    }
}

/// Enables the app to create a new image from any rectangular shapes that may exist in the user's environment.
extension DetectionViewController: AlteredImageDelegate {
    func alteredImageLostTracking(_ alteredImage: AlteredImage) {
        searchForNewImageToTrack()
    }
}
