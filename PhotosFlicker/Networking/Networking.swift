//
//  Networking.swift
//  PhotosFlicker
//
//  Created by Eyal Avissar on 17/08/2021.
//  Copyright © 2021 Eyal Avissar. All rights reserved.
//

import Foundation
import Alamofire

class NetworkManager {
    
    static let shared = NetworkManager()
    
    private init(){}
    
    var manager = NetworkReachabilityManager(host: "www.apple.com")
    
    var isWifi = false
    
//    fileprivate var isReachable = false
    
    func startMonitoring() {
        manager?.startListening { (networkStatus) in

            switch networkStatus {
            case .reachable(.cellular):
                print("reachable cellular")
                self.isWifi = false
            case .reachable(.ethernetOrWiFi):
                print("reachable wifi/ethernet")
                self.isWifi = true
            default:
                print("no network connection")
                self.isWifi = false
            }
        }
    }
    
    func isConnected() -> Bool {
        return manager?.isReachable ?? false
    }
}

