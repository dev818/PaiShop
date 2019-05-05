//
//  CategoryAPI.swift
//  paishop
//
//  Created by SeniorCorder on 6/15/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class CategoryAPI {
    static let shared = CategoryAPI()
    
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
    
    
    
    func itemFind(loadAll: Bool = false, page: Int, params: Parameters, completion: @escaping (JSON, Bool) -> Void) {
        let url = String(format: API.ITEM_FIND, "\(page)")
        
        if loadAll {
            Alamofire.request(url, method: .post, headers: headers).responseJSON { (response) in
                guard response.result.isSuccess else {
                    print("Error while fetching data: \(String(describing: response.result.error))")
                    completion(JSON.null, false)
                    return
                }
                
                if let result = response.result.value {
                    print("******************** ITEM_FIND ALL **********************")
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
            Alamofire.request(url, method: .post, parameters: params, headers: headers).responseJSON { (response) in
                guard response.result.isSuccess else {
                    print("Error while fetching data: \(String(describing: response.result.error))")
                    completion(JSON.null, false)
                    return
                }
                
                if let result = response.result.value {
                    print("******************** ITEM_FIND **********************")
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
    
    // get category first
    func getCategoryFirst(params: Parameters, completion: @escaping (NSDictionary, Bool) -> Void) {
        Alamofire.request(API.CATEGORY_FIRST, method: .post, parameters: params).responseJSON { response in
            if response.result.isSuccess {
                completion(response.result.value as! NSDictionary, true)
                return
                
            } else {
                completion(NSDictionary(), false)
                return
            }
            
        }
    }
    
    // get category sub
    func getCategorySub(params: Parameters, completion: @escaping (NSDictionary, Bool) -> Void) {
        Alamofire.request(API.CATEGORY_SUB, method: .post, parameters: params).responseJSON { response in
            if response.result.isSuccess {
                completion(response.result.value as! NSDictionary, true)
                return
                
            } else {
                completion(NSDictionary(), false)
                return
            }
            
        }
    }
    
    // get banners
    func getBanners(params: Parameters, completion: @escaping (NSDictionary, Bool) -> Void) {
        Alamofire.request(API.NOTIFICATION_BANNERS, method: .post, parameters: params).responseJSON { response in
            if response.result.isSuccess {
                completion(response.result.value as! NSDictionary, true)
                return
                
            } else {
                completion(NSDictionary(), false)
                return
            }
            
        }
    }
    
    // get top rank items
    func getItemGood(params: Parameters, completion: @escaping (JSON, Bool) -> Void) {
        Alamofire.request(API.ITEM_GOOD, method: .post, parameters: params, headers: getHeader()).responseJSON { (response) in
            guard response.result.isSuccess else {
                print("Error while fetching data: \(String(describing: response.result.error))")
                completion(JSON.null, false)
                return
            }
            
            if let result = response.result.value {
                print("******************** CONTACT_DEFAULT **********************")
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














