//
//  TaggedPhoto.swift
//  PhotosFlicker
//
//  Created by Eyal Avissar on 10/08/2021.
//  Copyright © 2021 Eyal Avissar. All rights reserved.
//

import Foundation

struct TaggedPhoto: Codable {
    let photoId = UUID()
    let name: String
    let latitude: Double
    let longitude: Double
    let photoURLString: String
}
