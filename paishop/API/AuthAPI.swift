
import Foundation
import Alamofire
import SwiftyJSON

class AuthAPI {
    static let shared = AuthAPI()
    
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
    
    /*  "phone_number": "13234116873",
        "reset_password": true
     */
    func sendVerifyCode(params: Parameters, completion: @escaping (JSON, Bool) -> Void) {
        manager.request(API.SEND_VERIFY_CODE, method: .post, parameters: params, headers: headers).responseJSON { (response) in
            guard response.result.isSuccess else {
                print("Error while fetching data: \(String(describing: response.result.error))")
                completion(JSON.null, false)
                return
            }
            
            if let result = response.result.value {
                //print("******************** SEND_VERIFY_CODE **********************")
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
    
    /*  "name": "Admin User",
        "phone_number": "13234116873",
        "email": "admin@gmail.com", optional
        "password": "password",
        "verify_code": "902369"
     */
    func register(params: Parameters, completion: @escaping(JSON, Bool)->Void ) {
        Alamofire.request(API.REGISTER, method: .post, parameters: params, headers: headers).responseJSON { (response) in
            guard response.result.isSuccess else {
                print("Error while fetching data: \(String(describing: response.result.error))")
                completion(JSON.null, false)
                return
            }
            
            if let result = response.result.value {
                print("******************** REGISTER **********************")
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
    
    /*  "name": "chihongzhe", if has name, pai login
        "phone_number": "13234116873", if has phone_number, general login
        "password": "password123"
     */
    func login(params: Parameters, completion: @escaping(JSON, Bool)->Void ) {
        Alamofire.request(API.LOGIN, method: .post, parameters: params, headers: headers).responseJSON { (response) in
            guard response.result.isSuccess else {
                print("Error while fetching data: \(String(describing: response.result.error))")
                completion(JSON.null, false)
                return
            }
            
            if let result = response.result.value {
                //print("******************** LOGIN **********************")
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
     "token":"8e69b25d7418cbfa3bd36cbf66fed3976862135cc77d0400927277a49950c796"
     */
    func logout(params: Parameters, completion: @escaping(Bool)->Void) {
        Alamofire.request(API.LOGOUT, method: .post, parameters: params, headers: getHeader()).responseJSON { (response) in
            print("******************** LOGOUT **********************")
            print(response)
            completion(true)
        }
    }
    
    /*  "phone_number":13234116873,
        "verify_code": 376812
     */
    func forgorPassword(params: Parameters, completion: @escaping(JSON, Bool)->Void) {
        Alamofire.request(API.FORGOT_PASSWORD, method: .post, parameters: params, headers: headers).responseJSON { (response) in
            guard response.result.isSuccess else {
                print("Error while fetching data: \(String(describing: response.result.error))")
                completion(JSON.null, false)
                return
            }
            
            if let result = response.result.value {
                //print("******************** FORGOT_PASSWORD **********************")
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
    
    /*  "phone_number": "13234116873",
        "password":"password123",
        "token":"8e69b25d7418cbfa3bd36cbf66fed3976862135cc77d0400927277a49950c796"
     */
    func resetPassword(params: Parameters, completion: @escaping(JSON, Bool)->Void) {
        Alamofire.request(API.RESET_PASSWORD, method: .post, parameters: params).responseJSON { (response) in
            guard response.result.isSuccess else {
                print("Error while fetching data: \(String(describing: response.result.error))")
                completion(JSON.null, false)
                return
            }
            
            if let result = response.result.value {
                //print("******************** FORGOT_PASSWORD **********************")
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
    
    
    func profileGet(completion: @escaping(JSON, Bool)->Void) {
        Alamofire.request(API.PROFILE_GET, method: .post, headers: getHeader()).responseJSON { (response) in
            guard response.result.isSuccess else {
                print("Error while fetching data: \(String(describing: response.result.error))")
                completion(JSON.null, false)
                return
            }
            
            if let result = response.result.value {
                //print("******************** PROFILE_GET **********************")
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
    
    /*func profileSet(image: UIImage?, params: Parameters, completion: @escaping(JSON, Bool)->Void) {
        var imageData: Data!
        if image != nil {
            imageData = UIImageJPEGRepresentation(image!, 0.3)
        }
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            if imageData != nil {
                multipartFormData.append(imageData!, withName: "profile_image", fileName: "profile_image.jpg", mimeType: "image/jpeg")
            }
            for (key, value) in params {
                if value is String {
                    multipartFormData.append((value as AnyObject).data(using: String.Encoding.utf8.rawValue)!, withName: key)
                }
            }
        }, to: API.PROFILE_SET,
           method:.post,
           headers:getHeader()) { (encodingResult) in
            switch encodingResult {
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    guard response.result.isSuccess else {
                        print("Error while fetching data: \(String(describing: response.result.error))")
                        completion(JSON.null, false)
                        return
                    }
                    
                    if let result = response.result.value {
                        print("******************** PROFILE_SET **********************")
                        print(result)
                        let data = JSON(result)
                        if (200..<300).contains(response.response!.statusCode) {
                            completion(data, true)
                        } else {
                            completion(data, false)
                        }
                    }                    
                }
            case .failure(let encodingError):
                print(encodingError)
                completion(JSON.null, false)
            }
        }
    }*/
    func profileSet(params: Parameters, completion: @escaping (JSON, Bool) -> Void) {
        Alamofire.request(API.PROFILE_SET, method: .post, parameters: params, headers: getHeader()).responseJSON { (response) in
            guard response.result.isSuccess else {
                print("Error while fetching data: \(String(describing: response.result.error))")
                completion(JSON.null, false)
                return
            }
            
            if let result = response.result.value {
                print("******************** PROFILE_SET **********************")
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
    
    /*
     "token" : "2358838948293489234eeds"
     "system" : true
    */
    func deviceToken(params: Parameters, completion: @escaping (JSON, Bool) -> Void) {
        Alamofire.request(API.DEVICE_TOKEN, method: .post, parameters: params, headers: getHeader()).responseJSON { (response) in
            guard response.result.isSuccess else {
                print("Error while fetching data: \(String(describing: response.result.error))")
                completion(JSON.null, false)
                return
            }
            
            if let result = response.result.value {
                print("******************** DEVICE_TOKEN **********************")
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
    
    
    /*
     "token" : "2358838948293489234eeds"
     */
    func deviceRefresh(params: Parameters, completion: @escaping (JSON, Bool) -> Void) {
        Alamofire.request(API.DEVICE_REFRESH, method: .post, parameters: params, headers: getHeader()).responseJSON { (response) in
            guard response.result.isSuccess else {
                print("Error while fetching data: \(String(describing: response.result.error))")
                completion(JSON.null, false)
                return
            }
            
            if let result = response.result.value {
                print("******************** DEVICE_REFRESH **********************")
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
    
    
    func paiLogin(params: Parameters, completion: @escaping (JSON, Bool) -> Void) {
        Alamofire.request("https://open-w.pigamewallet.com/businessopen/businessLogin", method: .post, parameters: params, headers: headers).responseJSON { (response) in
            guard response.result.isSuccess else {
                print("Error while fetching data: \(String(describing: response.result.error))")
                completion(JSON.null, false)
                return
            }
            
            if let result = response.result.value {
                print("******************** PAI_LOGIN **********************")
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











