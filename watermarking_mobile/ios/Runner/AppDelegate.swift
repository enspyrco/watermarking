import UIKit
import Flutter

enum ChannelName {
    static let detect = "watermarking.enspyr.co/detect"
}

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?
  ) -> Bool {
    
    GeneratedPluginRegistrant.register(with: self)
    
    CIFilter.registerName("WeightedCombine", constructor: CustomFiltersVendor(), classAttributes: [kCIAttributeFilterCategories: [kCICategoryVideo, kCICategoryStillImage]])
    
    guard let controller = window?.rootViewController as? FlutterViewController else {
        fatalError("rootViewController is not type FlutterViewController")
    }
    let detectChannel = FlutterMethodChannel(name: ChannelName.detect, binaryMessenger: controller)
    detectChannel.setMethodCallHandler({
        [weak self] (call: FlutterMethodCall, result: FlutterResult) -> Void in
        
        guard call.method == "startDetection" else {
            result(FlutterMethodNotImplemented)
            return
        }
        
        // navigate to DetectionViewController
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "DetectionVC") as! DetectionViewController
        controller.present(viewController, animated: true, completion: nil)
        
    })
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
