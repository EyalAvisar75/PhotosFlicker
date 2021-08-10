//
//  ViewController.swift
//  PhotosFlicker
//
//  Created by Eyal Avissar on 05/08/2021.
//  Copyright © 2021 Eyal Avissar. All rights reserved.
//

import UIKit
import CoreLocation

class PhotosController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    //MARK:- Properties
    var photosModel = TaggedPhotosModel()
    
    //MARK:- IBActions
    @IBAction func printTaggedImageData() {
        getImageData()
    }
    
    //MARK:- View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .green
        takeAPicture()
    }
    
    //MARK:- Helper Methods
    
    func takeAPicture() {
        let imageController = UIImagePickerController()
        
        imageController.sourceType = UIImagePickerController.isSourceTypeAvailable(.camera) ? .camera : .photoLibrary

        imageController.allowsEditing = true
        imageController.delegate = self
        present(imageController, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        print("In func imagePickerController")
        
        guard let image = info[.editedImage] as? UIImage else {
            print("No image found")
            return
        }
        
        saveTaggedImage(image)
                
        picker.dismiss(animated: true)
        print(image.size)
    }
    
    
    func saveTaggedImage(_ image:UIImage) {
        var fileNameStr = ""
        
        if let data = image.pngData() {
            
            let filename = URL(fileURLWithPath: photosModel.getFilePath())
            fileNameStr = filename.path
            try? data.write(to: filename)
        }
        
        let location = CLLocation(latitude: 30.7046, longitude: 76.7179)

        var taggedPhoto = TaggedPhoto(name: fileNameStr, latitude: 30.7046, longitude: 76.7179, photoURLString: fileNameStr)
        
        photosModel.addPhoto(photo: taggedPhoto)        
    }
    
    func getImageData() {
//        let path = getFilePath()
//        print(path)
//
//        let image = UIImage(contentsOfFile: path)
//        if image != nil {
//            print("has image")
//        }
//        else {
//            print("No image")
//        }
        
        print("model",photosModel.getModel())
//        let last =  photosModel.getModel().count
//
//        if last > 0 {
//            print(last)
//            let lastTaggedPhoto = photosModel.getPhoto(at: last - 1)
//            print("lastTaggedPhoto", lastTaggedPhoto)
//        }
    }
}

