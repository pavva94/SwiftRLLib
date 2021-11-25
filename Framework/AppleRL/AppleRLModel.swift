//
// AppleRLModel.swift
//
// This file was automatically generated and should not be edited.
//

import CoreML


/// Model Prediction Input Type
@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
class AppleRLModelInput : MLFeatureProvider {

    /// data as 1 element vector of doubles
    var data: MLMultiArray

    var featureNames: Set<String> {
        get {
            return ["data"]
        }
    }
    
    func featureValue(for featureName: String) -> MLFeatureValue? {
        if (featureName == "data") {
            return MLFeatureValue(multiArray: data)
        }
        return nil
    }
    
    init(data: MLMultiArray) {
        self.data = data
    }

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    convenience init(data: MLShapedArray<Double>) {
        self.init(data: MLMultiArray(data))
    }

}


/// Model Prediction Output Type
@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
class AppleRLModelOutput : MLFeatureProvider {

    /// Source provided by CoreML
    private let provider : MLFeatureProvider

    /// actions as 5 element vector of doubles
    lazy var actions: MLMultiArray = {
        [unowned self] in return self.provider.featureValue(for: "actions")!.multiArrayValue
    }()!

    /// actions as 5 element vector of doubles
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    var actionsShapedArray: MLShapedArray<Double> {
        return MLShapedArray<Double>(self.actions)
    }

    var featureNames: Set<String> {
        return self.provider.featureNames
    }
    
    func featureValue(for featureName: String) -> MLFeatureValue? {
        return self.provider.featureValue(for: featureName)
    }

    init(actions: MLMultiArray) {
        self.provider = try! MLDictionaryFeatureProvider(dictionary: ["actions" : MLFeatureValue(multiArray: actions)])
    }

    init(features: MLFeatureProvider) {
        self.provider = features
    }
}


/// Model Update Input Type
@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
class AppleRLModelTrainingInput : MLFeatureProvider {

    /// data as 1 element vector of doubles
    var data: MLMultiArray

    /// actions_true as 5 element vector of doubles
    var actions_true: MLMultiArray

    var featureNames: Set<String> {
        get {
            return ["data", "actions_true"]
        }
    }
    
    func featureValue(for featureName: String) -> MLFeatureValue? {
        if (featureName == "data") {
            return MLFeatureValue(multiArray: data)
        }
        if (featureName == "actions_true") {
            return MLFeatureValue(multiArray: actions_true)
        }
        return nil
    }
    
    init(data: MLMultiArray, actions_true: MLMultiArray) {
        self.data = data
        self.actions_true = actions_true
    }

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    convenience init(data: MLShapedArray<Double>, actions_true: MLShapedArray<Double>) {
        self.init(data: MLMultiArray(data), actions_true: MLMultiArray(actions_true))
    }

}


/// Class for model loading and prediction
@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
class AppleRLModel {
    let model: MLModel

    /// URL of model assuming it was installed in the same bundle as this class
    class var urlOfModelInThisBundle : URL {
        let bundle = Bundle(for: self)
        return bundle.url(forResource: "AppleRLModel", withExtension:"mlmodelc")!
    }

    /**
        Construct AppleRLModel instance with an existing MLModel object.

        Usually the application does not use this initializer unless it makes a subclass of AppleRLModel.
        Such application may want to use `MLModel(contentsOfURL:configuration:)` and `AppleRLModel.urlOfModelInThisBundle` to create a MLModel object to pass-in.

        - parameters:
          - model: MLModel object
    */
    init(model: MLModel) {
        self.model = model
    }

    /**
        Construct AppleRLModel instance by automatically loading the model from the app's bundle.
    */
    @available(*, deprecated, message: "Use init(configuration:) instead and handle errors appropriately.")
    convenience init() {
        try! self.init(contentsOf: type(of:self).urlOfModelInThisBundle)
    }

    /**
        Construct a model with configuration

        - parameters:
           - configuration: the desired model configuration

        - throws: an NSError object that describes the problem
    */
    convenience init(configuration: MLModelConfiguration) throws {
        try self.init(contentsOf: type(of:self).urlOfModelInThisBundle, configuration: configuration)
    }

    /**
        Construct AppleRLModel instance with explicit path to mlmodelc file
        - parameters:
           - modelURL: the file url of the model

        - throws: an NSError object that describes the problem
    */
    convenience init(contentsOf modelURL: URL) throws {
        try self.init(model: MLModel(contentsOf: modelURL))
    }

    /**
        Construct a model with URL of the .mlmodelc directory and configuration

        - parameters:
           - modelURL: the file url of the model
           - configuration: the desired model configuration

        - throws: an NSError object that describes the problem
    */
    convenience init(contentsOf modelURL: URL, configuration: MLModelConfiguration) throws {
        try self.init(model: MLModel(contentsOf: modelURL, configuration: configuration))
    }

    /**
        Construct AppleRLModel instance asynchronously with optional configuration.

        Model loading may take time when the model content is not immediately available (e.g. encrypted model). Use this factory method especially when the caller is on the main thread.

        - parameters:
          - configuration: the desired model configuration
          - handler: the completion handler to be called when the model loading completes successfully or unsuccessfully
    */
    @available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *)
    class func load(configuration: MLModelConfiguration = MLModelConfiguration(), completionHandler handler: @escaping (Swift.Result<AppleRLModel, Error>) -> Void) {
        return self.load(contentsOf: self.urlOfModelInThisBundle, configuration: configuration, completionHandler: handler)
    }

    /**
        Construct AppleRLModel instance asynchronously with optional configuration.

        Model loading may take time when the model content is not immediately available (e.g. encrypted model). Use this factory method especially when the caller is on the main thread.

        - parameters:
          - configuration: the desired model configuration
    */
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    class func load(configuration: MLModelConfiguration = MLModelConfiguration()) async throws -> AppleRLModel {
        return try await self.load(contentsOf: self.urlOfModelInThisBundle, configuration: configuration)
    }

    /**
        Construct AppleRLModel instance asynchronously with URL of the .mlmodelc directory with optional configuration.

        Model loading may take time when the model content is not immediately available (e.g. encrypted model). Use this factory method especially when the caller is on the main thread.

        - parameters:
          - modelURL: the URL to the model
          - configuration: the desired model configuration
          - handler: the completion handler to be called when the model loading completes successfully or unsuccessfully
    */
    @available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *)
    class func load(contentsOf modelURL: URL, configuration: MLModelConfiguration = MLModelConfiguration(), completionHandler handler: @escaping (Swift.Result<AppleRLModel, Error>) -> Void) {
        MLModel.load(contentsOf: modelURL, configuration: configuration) { result in
            switch result {
            case .failure(let error):
                handler(.failure(error))
            case .success(let model):
                handler(.success(AppleRLModel(model: model)))
            }
        }
    }

    /**
        Construct AppleRLModel instance asynchronously with URL of the .mlmodelc directory with optional configuration.

        Model loading may take time when the model content is not immediately available (e.g. encrypted model). Use this factory method especially when the caller is on the main thread.

        - parameters:
          - modelURL: the URL to the model
          - configuration: the desired model configuration
    */
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    class func load(contentsOf modelURL: URL, configuration: MLModelConfiguration = MLModelConfiguration()) async throws -> AppleRLModel {
        let model = try await MLModel.load(contentsOf: modelURL, configuration: configuration)
        return AppleRLModel(model: model)
    }

    /**
        Make a prediction using the structured interface

        - parameters:
           - input: the input to the prediction as AppleRLModelInput

        - throws: an NSError object that describes the problem

        - returns: the result of the prediction as AppleRLModelOutput
    */
    func prediction(input: AppleRLModelInput) throws -> AppleRLModelOutput {
        return try self.prediction(input: input, options: MLPredictionOptions())
    }

    /**
        Make a prediction using the structured interface

        - parameters:
           - input: the input to the prediction as AppleRLModelInput
           - options: prediction options 

        - throws: an NSError object that describes the problem

        - returns: the result of the prediction as AppleRLModelOutput
    */
    func prediction(input: AppleRLModelInput, options: MLPredictionOptions) throws -> AppleRLModelOutput {
        let outFeatures = try model.prediction(from: input, options:options)
        return AppleRLModelOutput(features: outFeatures)
    }

    /**
        Make a prediction using the convenience interface

        - parameters:
            - data as 1 element vector of doubles

        - throws: an NSError object that describes the problem

        - returns: the result of the prediction as AppleRLModelOutput
    */
    func prediction(data: MLMultiArray) throws -> AppleRLModelOutput {
        let input_ = AppleRLModelInput(data: data)
        return try self.prediction(input: input_)
    }

    /**
        Make a prediction using the convenience interface

        - parameters:
            - data as 1 element vector of doubles

        - throws: an NSError object that describes the problem

        - returns: the result of the prediction as AppleRLModelOutput
    */

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    func prediction(data: MLShapedArray<Double>) throws -> AppleRLModelOutput {
        let input_ = AppleRLModelInput(data: data)
        return try self.prediction(input: input_)
    }

    /**
        Make a batch prediction using the structured interface

        - parameters:
           - inputs: the inputs to the prediction as [AppleRLModelInput]
           - options: prediction options 

        - throws: an NSError object that describes the problem

        - returns: the result of the prediction as [AppleRLModelOutput]
    */
    func predictions(inputs: [AppleRLModelInput], options: MLPredictionOptions = MLPredictionOptions()) throws -> [AppleRLModelOutput] {
        let batchIn = MLArrayBatchProvider(array: inputs)
        let batchOut = try model.predictions(from: batchIn, options: options)
        var results : [AppleRLModelOutput] = []
        results.reserveCapacity(inputs.count)
        for i in 0..<batchOut.count {
            let outProvider = batchOut.features(at: i)
            let result =  AppleRLModelOutput(features: outProvider)
            results.append(result)
        }
        return results
    }
}
