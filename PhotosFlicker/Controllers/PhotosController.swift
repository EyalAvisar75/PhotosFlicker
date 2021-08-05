//
//  ViewController.swift
//  PhotosFlicker
//
//  Created by Eyal Avissar on 05/08/2021.
//  Copyright © 2021 Eyal Avissar. All rights reserved.
//

import UIKit
import Photos
import CoreLocation
import ImageIO

class PhotosController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    var asset = PHAsset()
    
    //MARK:- IBActions
    @IBAction func showImageMetaData() {
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
        
        asset = info[UIImagePickerController.InfoKey.phAsset] as! PHAsset

        print("In func  imagePickerController")
        
        guard let image = info[.editedImage] as? UIImage else {
            print("No image found")
            return
        }
        
        let location = CLLocation(latitude: 30.7046, longitude: 76.7179)

        /// It will return image metaData including location
        let metaData = self.addLocation(location, toImage: image)

        /// Saving the image to gallery
        self.saveImage(image, withMetadata: metaData)
        
        picker.dismiss(animated: true)
        print(image.size)
    }
    
    func addLocation(_ location: CLLocation, toImage image: UIImage) -> Dictionary<String, Any> {

        /// Initializing the metaData dict
        var metaData: Dictionary<String, Any> = [:]

        /// Check if image already have its meta data
        if let ciImage = image.ciImage {
            metaData = ciImage.properties
        }

        /// Initializing the gpsData dict
        var gpsData: Dictionary<String, Any> = [:]

        /// Check if there is any gps information
        if let gps = metaData[kCGImagePropertyGPSDictionary as String] as? Dictionary<String, Any> {
            gpsData = gps
        }

        /// Adding all the required information to gpsData dictionary
        // #1. Data & Time
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy:MM:dd HH:mm:ss"
        let localDate = dateFormatter.string(from: location.timestamp)
        gpsData[kCGImagePropertyGPSTimeStamp as String] = localDate

        // #2. Latitude, Longitude
        var latitude  = location.coordinate.latitude
        var longitude = location.coordinate.longitude
        var latRef = ""
        var lngRef = ""
        if latitude < 0.0 {
            latitude *= -1.0
            latRef = "S"
        } else  {
            latRef = "N"
        }

        if longitude < 0.0 {
            longitude *= -1.0
            lngRef = "W"
        }
        else {
            lngRef = "E"
        }

        gpsData[kCGImagePropertyGPSLatitudeRef as String] = latRef
        gpsData[kCGImagePropertyGPSLongitudeRef as String] = lngRef
        gpsData[kCGImagePropertyGPSLatitude as String] = latitude
        gpsData[kCGImagePropertyGPSLongitude as String] = longitude

        // #3. Accuracy
        gpsData[kCGImagePropertyGPSDOP as String] = location.horizontalAccuracy

        // #4. Altitude
        gpsData[kCGImagePropertyGPSAltitude as String] = location.altitude

        /// You can add what more you want to add into gpsData and after that
        /// Add this gpsData information into metaData dictionary
        metaData[kCGImagePropertyGPSDictionary as String] = gpsData

        return metaData
    }
    
    func saveImage(_ image:UIImage, withMetadata metaData: Dictionary<String, Any>) {
        /// Creating jpgData from UIImage (1 = original quality)
        guard let jpgData = image.jpegData(compressionQuality: 1) else { return }

        /// Adding metaData to jpgData
        guard let source = CGImageSourceCreateWithData(jpgData as CFData, nil), let uniformTypeIdentifier = CGImageSourceGetType(source) else {
            return
        }

        let finalData = NSMutableData(data: jpgData)
        guard let destination = CGImageDestinationCreateWithData(finalData, uniformTypeIdentifier, 1, nil) else { return }
        CGImageDestinationAddImageFromSource(destination, source, 0, metaData as CFDictionary)
        guard CGImageDestinationFinalize(destination) else { return }


        /// Your destination file path
        let filePath = getFilePath()
        let fileURL = URL(string: filePath)
        
        /// Now write this image to directory
        if FileManager.default.fileExists(atPath: filePath) {
            try? FileManager.default.removeItem(atPath: filePath)
        }

        let success = FileManager.default.createFile(atPath: filePath, contents: finalData as Data, attributes: [FileAttributeKey.protectionKey : FileProtectionType.complete])
        if success {
            /// Finally Save image to Gallery
            /// Important you need PhotoGallery permission before performing below operation.
            try? PHPhotoLibrary.shared().performChangesAndWait {
                PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: fileURL!)
            }
        } else {
            print("save image failed")
        }
    }


    func getFilePath() -> String {
        let documentDirectoryPath = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        
        let finalPath = documentDirectoryPath.appendingPathComponent("finalImage.jpg")
        /// Your destination file path
        
        return finalPath.path
    }
    
    func getImageData() {
        let path = getFilePath()
        let fileURL = URL(string: path)!
        
        //get data if any

        PHImageManager.default().requestImageDataAndOrientation(for: asset, options: nil) { (data, responseString, imageOrient, info) in
            let imageData: NSData = data! as NSData
            if let imageSource = CGImageSourceCreateWithData(imageData, nil) {
                let imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil)! as! [String: Any]
                print("properties: ", imageProperties)
            }
        }
    }
}

