//
//  ViewController.swift
//  PhotosFlicker
//
//  Created by Eyal Avissar on 05/08/2021.
//  Copyright © 2021 Eyal Avissar. All rights reserved.
//

import UIKit
import CoreLocation

class PhotosController: UIViewController, UINavigationControllerDelegate {
    
    //MARK:- Properties
    private var locationManager: CLLocationManager!
    var currentLocation: CLLocation?
    var photosModel = TaggedPhotosModel()
    
    //MARK:- IBActions
    @IBAction func printTaggedImageData() {
        getImageData()
    }
    
    @IBAction func pictureThat() {
        takeAPicture()
    }
    
    //MARK:- View Lifecycle
    override func viewDidLoad() {
        authorizeLocationRequests()
        super.viewDidLoad()
    }
    
    //MARK:- Helper Methods
    
    func takeAPicture() {
//        getUserLocation()

        let imageController = UIImagePickerController()
        
        imageController.sourceType = UIImagePickerController.isSourceTypeAvailable(.camera) ? .camera : .photoLibrary

        imageController.allowsEditing = true
        imageController.delegate = self
        present(imageController, animated: true)
    }
    
    
    
    
    func saveTaggedImage(_ image:UIImage) {
        guard let location = currentLocation else {
            print("No current location")
            return
        }
        
        var fileNameStr = ""
        
        if let data = image.pngData() {
            let filename = URL(fileURLWithPath: photosModel.getFilePath())
            fileNameStr = filename.path
            try? data.write(to: filename)
        }
        
        
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        
        let taggedPhoto = TaggedPhoto(name: fileNameStr, latitude: latitude, longitude: longitude, photoURLString: fileNameStr)
        
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

extension PhotosController: CLLocationManagerDelegate {
    func authorizeLocationRequests() {
        if (CLLocationManager.locationServicesEnabled())
        {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            currentLocation = location
        }
    }
}

extension PhotosController: UIImagePickerControllerDelegate {
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
}



