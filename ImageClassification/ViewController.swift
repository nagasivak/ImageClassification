//
//  ViewController.swift
//  ImageClassification
//
//  Created by Naga Siva on 09/02/21.
//

import UIKit
import CoreML
import Vision


class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var resultUIView: UIView!
    @IBOutlet weak var resultOne: UILabel!
    @IBOutlet weak var accuracy: UILabel!
    @IBOutlet weak var takenImageView: UIImageView!
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        resultUIView.isHidden = true
        resultUIView.layer.cornerRadius = 10
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
        // Do any additional setup after loading the view.
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let userPickedImage = info[.originalImage] as? UIImage {
            takenImageView.image = userPickedImage
            guard let ciimage = CIImage(image: userPickedImage) else {
                fatalError("Cannot convert UIImage to CIImage")
            }
            detect(image: ciimage)
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
        
    }
    
    func detect(image: CIImage) {
        
        guard let model =  try? VNCoreMLModel(for: Inceptionv3().model) else {
            fatalError("Loading Model Failed")
        }
        
        //        guard let model =  try? VNCoreMLModel(for: Resnet50().model) else {
        //            fatalError("Loading Model Failed")
        //        }
        
        //        guard let model =  try? VNCoreMLModel(for: MobileNetV2().model) else {
        //            fatalError("Loading Model Failed")
        //        }
        
        //        guard let model =  try? VNCoreMLModel(for: SqueezeNet().model) else {
        //            fatalError("Loading Model Failed")
        //        }
        
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("Cannot obtain results")
            }
            
            if let firstResult = results.first {
                let confidence = firstResult.value(forKey: "confidence") as! Double
                let doubleStr = String(format: "%.2f", confidence * 100)
                DispatchQueue.main.async {
                    self.resultUIView.isHidden = false
                    self.resultOne.text = "\(firstResult.identifier)"
                    self.accuracy.text = "Accuracy  : " + doubleStr
                }
            }
        }
        let handler = VNImageRequestHandler(ciImage: image)
        do {
            try handler.perform([request])
        }
        catch {
            print(error)
        }
    }
    
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        present(imagePicker, animated: true, completion: nil)
    }
    
}

