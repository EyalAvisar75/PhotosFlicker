//
//  TaggedPhotosModel.swift
//  PhotosFlicker
//
//  Created by Eyal Avissar on 10/08/2021.
//  Copyright © 2021 Eyal Avissar. All rights reserved.
//

import Foundation

/*
 
 static var documentsDirectory: URL {
 let documentsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
 return try! documentsDirectory.asURL()
 }
 
 static func urlInDocumentsDirectory(with filename: String) -> URL {
 return documentsDirectory.appendingPathComponent(filename)
 }
 */
struct TaggedPhotosModel {
    private var photosModel = [TaggedPhoto]()
    private let documentDirectoryPath = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    private var currentPictureName = "0"
    
    mutating func populatePhotosModel() {
        var taggedPhotoJsons = [URL]()
        do {
            let documentsURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            taggedPhotoJsons = try FileManager.default.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil, options:  .skipsHiddenFiles)
            taggedPhotoJsons = taggedPhotoJsons.filter{ $0.pathExtension == "json" }
            print("jsons",taggedPhotoJsons)
        } catch {
            print(error)
        }
        
        for json in taggedPhotoJsons {
            do {
                let data = try Data(contentsOf: URL(resolvingAliasFileAt: json), options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                if let jsonResult = jsonResult as? Dictionary<String, AnyObject> {
                    print("jsonResult",jsonResult)
                    
                    let taggedPhoto = TaggedPhoto(name: jsonResult["name"] as! String, latitude: jsonResult["latitude"] as! Double, longitude: jsonResult["longitude"] as! Double, photoURLString: jsonResult["photoURLString"] as! String)
                    
                    photosModel.append(taggedPhoto)
                }
                
            } catch {
                // handle error
            }
        }
    }
    
    mutating func getModel() -> [TaggedPhoto] {
        populatePhotosModel()
        return photosModel
    }
    
    func getPhoto(at index: Int) -> TaggedPhoto {
        return photosModel[index]
    }
    
    mutating func addPhoto(photo: TaggedPhoto) {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        do {
            let jsonData = try encoder.encode(photo)
            
            if let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {

                let finalDocumentDirectory = documentDirectory.appendingPathComponent("\(currentPictureName).json")
                let jsonFile =  URL(fileURLWithPath: finalDocumentDirectory.path)
                    print("json file", jsonFile)
                    try jsonData.write(to: jsonFile)
                    
                    let read = try Data(contentsOf: jsonFile)
                    
                    print(String(data: read, encoding: .utf8)!)
                    
            }
        } catch {
            print(error.localizedDescription)
        }
        
        photosModel.append(photo)
    }
    
    mutating func getFilePath() -> String {
        let pictureName = Int.random(in: 1...10000)
        currentPictureName = String(pictureName)
        let finalPath = documentDirectoryPath.appendingPathComponent("\(pictureName).jpg")
        /// Your destination file path
        
        print(finalPath.path)
        return finalPath.path
    }
    
    
}
