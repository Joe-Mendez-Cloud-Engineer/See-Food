//
//  ViewController.swift
//  See-Food
//
//  Created by Joe Mendez on 6/4/17.
//  Copyright © 2017 Joe Mendez. All rights reserved.
//
import UIKit
import VisualRecognitionV3
import SVProgressHUD

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    private enum Constants {
        static let apiKey = SecureConfiguration.visualRecognitionAPIKey
        static let version = "2017-06-05"
        static let compressionQuality: CGFloat = 0.5
        static let tempImageFileName = "tempImage.jpg"
    }
    
    @IBOutlet private weak var topBarImageView: UIImageView!
    @IBOutlet private weak var viewOfImage: UIImageView!
    @IBOutlet private weak var buttonCamera: UIBarButtonItem!
    
    private let imagePicker = UIImagePickerController()
    private lazy var visualRecognition: VisualRecognition = {
        return VisualRecognition(apiKey: Constants.apiKey, version: Constants.version)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupImagePicker()
        setupNavigationBar()
    }
    

    @IBAction private func tapThatCamera(_ sender: UIBarButtonItem) {
        presentImagePicker()
    }
    
    func imagePickerController(_ picker: UIImagePickerController, 
                               didFinishPickingMediaWithInfo info: [String : Any]) {
        handleImageSelection(info: info)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        resetUIState()
        dismissImagePicker()
    }
}

private extension ViewController {
    func setupImagePicker() {
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
    }
    
    func setupNavigationBar() {
        navigationController?.navigationBar.isTranslucent = false
    }
}

private extension ViewController {
    func handleImageSelection(info: [String: Any]) {
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            showError(message: "Failed to get image")
            return
        }
        
        viewOfImage.image = image
        buttonCamera.isEnabled = false
        SVProgressHUD.show()
        
        dismissImagePicker { [weak self] in
            self?.classifyImage(image)
        }
    }
    
    func classifyImage(_ image: UIImage) {
        guard let imageData = UIImageJPEGRepresentation(image, Constants.compressionQuality) else {
            showError(message: "Image processing failed")
            return
        }
        
        visualRecognition.classify(image: imageData) { [weak self] response, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.buttonCamera.isEnabled = true
                SVProgressHUD.dismiss()
            }
            
            if let error = error {
                self.showError(message: error.localizedDescription)
                return
            }
            
            guard let classifiedImages = response?.result else {
                self.showError(message: "Classification failed")
                return
            }
            
            self.handleClassificationResult(classifiedImages)
        }
    }
    
    func handleClassificationResult(_ classifiedImages: ClassifiedImages) {
        guard let classes = classifiedImages.images.first?.classifiers.first?.classes else {
            showError(message: "No classifications found")
            return
        }
        
        let classifications = classes.map { $0.classification }
        let isHotDog = classifications.contains("hotdog")
        
        DispatchQueue.main.async { [weak self] in
            self?.updateUIForHotdogStatus(isHotDog)
        }
    }
}

private extension ViewController {
    func updateUIForHotdogStatus(_ isHotDog: Bool) {
        navigationItem.title = isHotDog ? "Hotdog" : "Not hotdog"
        let color = isHotDog ? UIColor.green : UIColor.red
        let imageName = isHotDog ? "hotdog" : "nothotdog"
        
        navigationController?.navigationBar.barTintColor = color
        topBarImageView.image = UIImage(named: imageName)
    }
    
    func resetUIState() {
        buttonCamera.isEnabled = true
        SVProgressHUD.dismiss()
    }
    
    func showError(message: String) {
        DispatchQueue.main.async { [weak self] in
            let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self?.present(alert, animated: true)
            self?.resetUIState()
        }
    }
}

private extension ViewController {
    func presentImagePicker() {
        present(imagePicker, animated: true)
    }
    
    func dismissImagePicker(completion: (() -> Void)? = nil) {
        imagePicker.dismiss(animated: true, completion: completion)
    }
}
