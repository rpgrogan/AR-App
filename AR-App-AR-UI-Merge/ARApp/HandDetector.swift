//
//  HandDetector.swift
//  ARApp
//
//  Created by admin on 4/27/20.
//  Copyright © 2020 GIMM. All rights reserved.
//

import CoreML
import Vision

public class HandDetector {
    
    private let visionQueue = DispatchQueue(label: "com.viseo.ARML.visionqueue")
    
    private lazy var predictionRequest: VNCoreMLRequest = {
        //Load teh ML Model through its generated class and create a vision request for it.
        do {
            let model = try VNCoreMLModel(for: HandModel().model)
            let request = VNCoreMLRequest(model: model)
            
            //this will deternmine whether the images are scaled correctly and then it will rescale if needed
            request.imageCropAndScaleOption = VNImageCropAndScaleOption.scaleFill
            return request
        } catch {
            fatalError("can't load Vision ML model: \(error)")
        }
    }()
    
    public func performDetection(inputBuffer: CVPixelBuffer, completion: @escaping (_ outputBuffer: CVPixelBuffer?, _ error: Error?) -> Void) {
        //This will right the orientation since the pixel data will be in the native language
        let requestHandler = VNImageRequestHandler(cvPixelBuffer: inputBuffer, orientation: .right)
        
        //We perform our CoreML Requests with async
        visionQueue.async {
            //run our CoreML request
            do {
                try requestHandler.perform([self.predictionRequest])
                
                guard let observation = self.predictionRequest.results?.first as? VNPixelBufferObservation else {
                    fatalError("Unexpected result type from VNCoreMLRequest")
                }
                
                //The resulting image(mask) is avaible as observation.pixelBuffer
                completion(observation.pixelBuffer, nil)
            } catch {
                completion(nil, error)
            }
        }
    }
}
