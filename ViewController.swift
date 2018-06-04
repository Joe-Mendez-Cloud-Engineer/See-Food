//
//  ViewController.swift
//  See-Food
//
//  Created by Joe Mendez on 6/4/17.
//  Copyright © 2017 Scientific Neo. All rights reserved.
//

import UIKit
import VisualRecognitionV3
import SVProgressHUD

class ViewController: UIViewController, UIImagePickerControllerDelegate,
    UINavigationControllerDelegate {
    
    let apiKey = "f7a367003747f83ffb4cf6cc5c620a81fc3c902f"
    let version = "2017-06-05"
    
    @IBOutlet weak var topBarImageView: UIImageView!
    @IBOutlet weak var viewOfImage: UIImageView!
    
    
    @IBOutlet weak var buttonCamera: UIBarButtonItem!
    
    
    let imagePicker = UIImagePickerController()
    var classificationResults : [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        buttonCamera.isEnabled = false
        SVProgressHUD.show()
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            viewOfImage.image = image
            
            imagePicker.dismiss(animated: true, completion: nil)
            
            let visualRicognition = VisualRecognition(apiKey: apiKey, version:version)
            
            let imageData = UIImageJPEGRepresentation(image, 0.01)
            
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            
            let fileURL = documentsURL.appendingPathComponent("tempImage.jpg")
            
            try? imageData?.write(to: fileURL, options: [])
            
            visualRicognition.classify(imageFile: fileURL, success:{
                (classifiedImages) in
                let classes = classifiedImages.images.first!.classifiers.first!.classes
                    
                self.classificationResults = []
                    
                for index in 0..<classes.count{
                    self.classificationResults.append(classes[index].classification)
                    }
                
                print(self.classificationResults)
                    
                DispatchQueue.main.async {
                        self.buttonCamera.isEnabled = true
                        SVProgressHUD.dismiss()
                    }
                    
                    if self.classificationResults.contains("hotdog"){
                        DispatchQueue.main.async {
                            self.navigationItem.title = "Hotdog"
                            self.navigationController?.navigationBar.barTintColor = UIColor.green
                            self.navigationController?.navigationBar.isTranslucent = false
                            self.topBarImageView.image = UIImage(named:"hotdog")
                        }
                        }
                        
                    else{
                        DispatchQueue.main.async {
                            
                            self.navigationItem.title = "Not hotdog"
                            self.navigationController?.navigationBar.barTintColor = UIColor.red
                            self.navigationController?.navigationBar.isTranslucent = false
                            self.topBarImageView.image = UIImage(named:"nothotdog")
                            
                        }
                        
                    }
            })
            
        } else {
            
            print("There was an error in processing this request")
        }
    }
    
    @IBAction func tapThatCamera(_ sender: UIBarButtonItem) {
        
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
        
        present(imagePicker, animated: true, completion: nil)
        
    }
}




