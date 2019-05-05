//
//  NearbyAPI.swift
//  paishop
//
//  Created by SeniorCorder on 6/16/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON


class NearbyAPI {
    static let shared = NearbyAPI()
    
    let headers: HTTPHeaders = [
        "Accept": "application/json"
    ]
    
    var manager: SessionManager!
    
    init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 60
        configuration.timeoutIntervalForResource = 60
        configuration.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders
        manager = Alamofire.SessionManager(configuration: configuration)
    }
    
    func getHeader() -> HTTPHeaders {
        let token = UserInstance.accessToken!
        let headers: HTTPHeaders = [
            "Accept": "application/json",
            "Authorization": "Bearer " + token
        ]
        return headers
    }
    
    func storeAround(loadAll: Bool = false, params: Parameters, completion: @escaping (JSON, Bool) -> Void) {
        if loadAll {
            Alamofire.request(API.STORE_AROUND, method: .post, headers: headers).responseJSON { (response) in
                guard response.result.isSuccess else {
                    print("Error while fetching data: \(String(describing: response.result.error))")
                    completion(JSON.null, false)
                    return
                }
                
                if let result = response.result.value {
                    print("******************** STORE_AROUND ALL **********************")
                    print(result)
                    let data = JSON(result)
                    if (200..<300).contains(response.response!.statusCode) {
                        completion(data, true)
                    } else {
                        completion(data, false)
                    }
                }
            }
        } else {
            Alamofire.request(API.STORE_AROUND, method: .post, parameters: params, headers: headers).responseJSON { (response) in
                guard response.result.isSuccess else {
                    print("Error while fetching data: \(String(describing: response.result.error))")
                    completion(JSON.null, false)
                    return
                }
                
                if let result = response.result.value {
                    print("******************** STORE_AROUND **********************")
                    print(result)
                    let data = JSON(result)
                    if (200..<300).contains(response.response!.statusCode) {
                        completion(data, true)
                    } else {
                        completion(data, false)
                    }
                }
            }
        }
        
    }
    
    
}

















