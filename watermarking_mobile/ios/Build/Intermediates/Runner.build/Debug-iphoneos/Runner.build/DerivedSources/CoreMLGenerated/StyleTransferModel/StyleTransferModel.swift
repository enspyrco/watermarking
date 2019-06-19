//
// StyleTransferModel.swift
//
// This file was automatically generated and should not be edited.
//

import CoreML


/// Model Prediction Input Type
@available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *)
class StyleTransferModelInput : MLFeatureProvider {

    /// Input image as color (kCVPixelFormatType_32BGRA) image buffer, 600 pixels wide by 600 pixels high
    var image: CVPixelBuffer

    /// Style index array (set index I to 1.0 to enable Ith style) as 8 element vector of doubles
    var index: MLMultiArray

    var featureNames: Set<String> {
        get {
            return ["image", "index"]
        }
    }
    
    func featureValue(for featureName: String) -> MLFeatureValue? {
        if (featureName == "image") {
            return MLFeatureValue(pixelBuffer: image)
        }
        if (featureName == "index") {
            return MLFeatureValue(multiArray: index)
        }
        return nil
    }
    
    init(image: CVPixelBuffer, index: MLMultiArray) {
        self.image = image
        self.index = index
    }
}

/// Model Prediction Output Type
@available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *)
class StyleTransferModelOutput : MLFeatureProvider {

    /// Source provided by CoreML

    private let provider : MLFeatureProvider


    /// Stylized image as color (kCVPixelFormatType_32BGRA) image buffer, 600 pixels wide by 600 pixels high
    lazy var stylizedImage: CVPixelBuffer = {
        [unowned self] in return self.provider.featureValue(for: "stylizedImage")!.imageBufferValue
    }()!

    var featureNames: Set<String> {
        return self.provider.featureNames
    }
    
    func featureValue(for featureName: String) -> MLFeatureValue? {
        return self.provider.featureValue(for: featureName)
    }

    init(stylizedImage: CVPixelBuffer) {
        self.provider = try! MLDictionaryFeatureProvider(dictionary: ["stylizedImage" : MLFeatureValue(pixelBuffer: stylizedImage)])
    }

    init(features: MLFeatureProvider) {
        self.provider = features
    }
}


/// Class for model loading and prediction
@available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *)
class StyleTransferModel {
    var model: MLModel

/// URL of model assuming it was installed in the same bundle as this class
    class var urlOfModelInThisBundle : URL {
        let bundle = Bundle(for: StyleTransferModel.self)
        return bundle.url(forResource: "StyleTransferModel", withExtension:"mlmodelc")!
    }

    /**
        Construct a model with explicit path to mlmodelc file
        - parameters:
           - url: the file url of the model
           - throws: an NSError object that describes the problem
    */
    init(contentsOf url: URL) throws {
        self.model = try MLModel(contentsOf: url)
    }

    /// Construct a model that automatically loads the model from the app's bundle
    convenience init() {
        try! self.init(contentsOf: type(of:self).urlOfModelInThisBundle)
    }

    /**
        Construct a model with configuration
        - parameters:
           - configuration: the desired model configuration
           - throws: an NSError object that describes the problem
    */
    @available(macOS 10.14, iOS 12.0, tvOS 12.0, watchOS 5.0, *)
    convenience init(configuration: MLModelConfiguration) throws {
        try self.init(contentsOf: type(of:self).urlOfModelInThisBundle, configuration: configuration)
    }

    /**
        Construct a model with explicit path to mlmodelc file and configuration
        - parameters:
           - url: the file url of the model
           - configuration: the desired model configuration
           - throws: an NSError object that describes the problem
    */
    @available(macOS 10.14, iOS 12.0, tvOS 12.0, watchOS 5.0, *)
    init(contentsOf url: URL, configuration: MLModelConfiguration) throws {
        self.model = try MLModel(contentsOf: url, configuration: configuration)
    }

    /**
        Make a prediction using the structured interface
        - parameters:
           - input: the input to the prediction as StyleTransferModelInput
        - throws: an NSError object that describes the problem
        - returns: the result of the prediction as StyleTransferModelOutput
    */
    func prediction(input: StyleTransferModelInput) throws -> StyleTransferModelOutput {
        return try self.prediction(input: input, options: MLPredictionOptions())
    }

    /**
        Make a prediction using the structured interface
        - parameters:
           - input: the input to the prediction as StyleTransferModelInput
           - options: prediction options 
        - throws: an NSError object that describes the problem
        - returns: the result of the prediction as StyleTransferModelOutput
    */
    func prediction(input: StyleTransferModelInput, options: MLPredictionOptions) throws -> StyleTransferModelOutput {
        let outFeatures = try model.prediction(from: input, options:options)
        return StyleTransferModelOutput(features: outFeatures)
    }

    /**
        Make a prediction using the convenience interface
        - parameters:
            - image: Input image as color (kCVPixelFormatType_32BGRA) image buffer, 600 pixels wide by 600 pixels high
            - index: Style index array (set index I to 1.0 to enable Ith style) as 8 element vector of doubles
        - throws: an NSError object that describes the problem
        - returns: the result of the prediction as StyleTransferModelOutput
    */
    func prediction(image: CVPixelBuffer, index: MLMultiArray) throws -> StyleTransferModelOutput {
        let input_ = StyleTransferModelInput(image: image, index: index)
        return try self.prediction(input: input_)
    }

    /**
        Make a batch prediction using the structured interface
        - parameters:
           - inputs: the inputs to the prediction as [StyleTransferModelInput]
           - options: prediction options 
        - throws: an NSError object that describes the problem
        - returns: the result of the prediction as [StyleTransferModelOutput]
    */
    @available(macOS 10.14, iOS 12.0, tvOS 12.0, watchOS 5.0, *)
    func predictions(inputs: [StyleTransferModelInput], options: MLPredictionOptions = MLPredictionOptions()) throws -> [StyleTransferModelOutput] {
        let batchIn = MLArrayBatchProvider(array: inputs)
        let batchOut = try model.predictions(from: batchIn, options: options)
        var results : [StyleTransferModelOutput] = []
        results.reserveCapacity(inputs.count)
        for i in 0..<batchOut.count {
            let outProvider = batchOut.features(at: i)
            let result =  StyleTransferModelOutput(features: outProvider)
            results.append(result)
        }
        return results
    }
}
