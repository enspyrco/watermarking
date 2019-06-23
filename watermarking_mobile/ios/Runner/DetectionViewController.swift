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
    @IBOutlet weak var imageView: UIImageView!

    static var instance: DetectionViewController?
    
    let filter: CIFilter = CIFilter(name: "WeightedCombine")!
    var foreground: CIImage? = nil
    var background: CIImage? = nil
    var numCombined: Int = 0
    let accumulator: CIImageAccumulator = CIImageAccumulator(extent: CGRect(x: 0, y: 0, width: 640, height: 640), format: kCIFormatARGB8)!
    
    /// An object that detects rectangular shapes in the user's environment.
    let rectangleDetector = RectangleDetector()
    
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
        
        let configuration = ARImageTrackingConfiguration()
        configuration.maximumNumberOfTrackedImages = 1
        configuration.trackingImages = []
        sceneView.session.run(configuration, options: [.removeExistingAnchors, .resetTracking])
	}
    
    /// Handles tap gesture input.
    @IBAction func didTap(_ sender: Any) {
        
    }
}

extension DetectionViewController: ARSCNViewDelegate {
    
    /// - Tag: ImageWasRecognized
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
    }

    /// - Tag: DidUpdateAnchor
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        guard let arError = error as? ARError else { return }
        
        if arError.code == .invalidReferenceImage {
            // Restart the experience, as otherwise the AR session remains stopped.
            // There's no benefit in surfacing this error to the user.
            print("Error: The detected rectangle cannot be tracked.")
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
        
        if background == nil {
            background = rectangleContent.copy() as? CIImage
        }
        else {
            background = accumulator.image()
        }
        
        numCombined += 1
        
        // setup and apply the filter
        filter.setValue(rectangleContent, forKey: kCIInputImageKey)
        filter.setValue(background, forKey: kCIInputBackgroundImageKey)
        filter.setValue(NSNumber(value: numCombined), forKey: kCIInputScaleKey)
        accumulator.setImage(filter.outputImage!)
        
        // display the new combine image 
        DispatchQueue.main.async {
            self.imageView.image = UIImage.init(ciImage: self.accumulator.image())
        }
        
    }
}

