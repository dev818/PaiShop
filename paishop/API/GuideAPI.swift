
import Foundation
import Alamofire
import SwiftyJSON


class GuideAPI {
    static let shared = GuideAPI()
    
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
    
    /*
     "lng": 120.0394,
     "lat": 56.4095,
     "radius": 100000 // m
     */
    func storeLocation(params: Parameters, completion: @escaping(JSON, Bool)->Void) {
        Alamofire.request(API.STORE_LOCATION, method: .post, parameters: params, headers: headers).responseJSON { (response) in
            guard response.result.isSuccess else {
                print("Error while fetching data: \(String(describing: response.result.error))")
                completion(JSON.null, false)
                return
            }
            
            if let result = response.result.value {
                //print("******************** STORE_LOCATION **********************")
                //print(result)
                let data = JSON(result)
                if (200..<300).contains(response.response!.statusCode) {
                    completion(data, true)
                } else {
                    completion(data, false)
                }
            }
        }
    }
    
    /*
     "id" : 38
    */
    func storeCity(params: Parameters, completion: @escaping(JSON, Bool)->Void) {
        Alamofire.request(API.STORE_CITY, method: .post, parameters: params, headers: headers).responseJSON { (response) in
            guard response.result.isSuccess else {
                print("Error while fetching data: \(String(describing: response.result.error))")
                completion(JSON.null, false)
                return
            }
            
            if let result = response.result.value {
                print("******************** STORE_CITY **********************")
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
    
    func storeCategory(page: Int, params: Parameters, completion: @escaping(JSON, Bool)->Void) {
        let url = String(format: API.STORE_CATEGORY, "\(page)")
        Alamofire.request(url, method: .post, parameters: params, headers: headers).responseJSON { (response) in
            guard response.result.isSuccess else {
                print("Error while fetching data: \(String(describing: response.result.error))")
                completion(JSON.null, false)
                return
            }
            
            if let result = response.result.value {
                //print("******************** STORE_CATEGORY **********************")
                //print(result)
                let data = JSON(result)
                if (200..<300).contains(response.response!.statusCode) {
                    completion(data, true)
                } else {
                    completion(data, false)
                }
            }
        }
    }
    
    func storeSearch(params: Parameters, completion: @escaping(JSON, Bool)->Void) {
        Alamofire.request(API.STORE_SEARCH, method: .post, parameters: params, headers: headers).responseJSON { (response) in
            guard response.result.isSuccess else {
                print("Error while fetching data: \(String(describing: response.result.error))")
                completion(JSON.null, false)
                return
            }
            
            if let result = response.result.value {
                //print("******************** STORE_SEARCH **********************")
                //print(result)
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
























