
import Foundation
import Alamofire
import SwiftyJSON

public struct MyAPI {
    
    static let shared = MyAPI()
    
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
    
    
    
    
    func cartList(params: Parameters, completion: @escaping (JSON, Bool) -> Void) {
        Alamofire.request(API.CART_LIST, method: .post, parameters: params, headers: getHeader()).responseJSON { (response) in
            guard response.result.isSuccess else {
                print("Error while fetching data: \(String(describing: response.result.error))")
                completion(JSON.null, false)
                return
            }
            
            if let result = response.result.value {
                print("******************** CART_LIST **********************")
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
     "id" : 66
     */
    func cartDetail(params: Parameters, completion: @escaping (JSON, Bool) -> Void) {
        Alamofire.request(API.CART_DETAIL, method: .post, parameters: params, headers: getHeader()).responseJSON { (response) in
            guard response.result.isSuccess else {
                print("Error while fetching data: \(String(describing: response.result.error))")
                completion(JSON.null, false)
                return
            }
            
            if let result = response.result.value {
                //print("******************** CART_DETAIL **********************")
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
     "id" : 66
     "count" : 4
    */
    func cartChange(params: Parameters, completion: @escaping (JSON, Bool) -> Void) {
        Alamofire.request(API.CART_CHANGE, method: .post, parameters: params, headers: getHeader()).responseJSON { (response) in
            guard response.result.isSuccess else {
                print("Error while fetching data: \(String(describing: response.result.error))")
                completion(JSON.null, false)
                return
            }
            
            if let result = response.result.value {
                //print("******************** CART_CHANGE **********************")
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
     "ids" : [35, 38, 29]
    */
    func cartDeletes(params: Parameters, completion: @escaping (JSON, Bool) -> Void) {
        Alamofire.request(API.CART_DELETES, method: .post, parameters: params, headers: getHeader()).responseJSON { (response) in
            guard response.result.isSuccess else {
                print("Error while fetching data: \(String(describing: response.result.error))")
                completion(JSON.null, false)
                return
            }
            
            if let result = response.result.value {
                //print("******************** CART_DELETES **********************")
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
     "id" : 66
     "count" : 3
    */
    func cartAdd(params: Parameters, completion: @escaping (JSON, Bool) -> Void) {
        Alamofire.request(API.CART_ADD, method: .post, parameters: params, headers: getHeader()).responseJSON { (response) in
            guard response.result.isSuccess else {
                print("Error while fetching data: \(String(describing: response.result.error))")
                completion(JSON.null, false)
                return
            }
            
            if let result = response.result.value {
                //print("******************** CART_ADD **********************")
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
    
    
    func itemMine(page: Int, completion: @escaping (JSON, Bool) -> Void) {
        let url = String(format: API.ITEM_MINE, "\(page)")
        Alamofire.request(url, method: .post, headers: getHeader()).responseJSON { (response) in
            guard response.result.isSuccess else {
                print("Error while fetching data: \(String(describing: response.result.error))")
                completion(JSON.null, false)
                return
            }
            
            if let result = response.result.value {
                //print("******************** ITEM_MINE **********************")
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
    
    func storeMine(completion: @escaping (JSON, Bool) -> Void) {
        Alamofire.request(API.STORE_MINE, method: .post, headers: getHeader()).responseJSON { (response) in
            guard response.result.isSuccess else {
                print("Error while fetching data: \(String(describing: response.result.error))")
                completion(JSON.null, false)
                return
            }
            
            if let result = response.result.value {
                //print("******************** STORE_MINE **********************")
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
    
    /*func itemRegister(images: [UIImage], params: Parameters, completion: @escaping (JSON, Bool) -> Void) {
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            for image in images {
                let imgData = UIImageJPEGRepresentation(image, 0.3)
                if let imageData = imgData {
                    let width = Int(image.size.width)
                    let height = Int(image.size.height)
                    let fileName = "\(width)x\(height).jpg"
                    print("File Name...", fileName)
                    multipartFormData.append(imageData, withName: "item_images[]", fileName: fileName, mimeType: "image/jpeg")
                }
            }
            for (key, value) in params {
                if value is String {
                    multipartFormData.append((value as AnyObject).data(using: String.Encoding.utf8.rawValue)!, withName: key)
                } else if value is Int64 {
                    var data = value as! Int64
                    let int64Data = Data(bytes: &data,
                                         count: MemoryLayout.size(ofValue: data))
                    multipartFormData.append(int64Data, withName: key)
                } else if value is Int {
                    var data = value as! Int
                    let intData = Data(bytes: &data,
                                       count: MemoryLayout.size(ofValue: data))
                    multipartFormData.append(intData, withName: key)
                }
            }
        }, to: API.ITEM_REGISTER,
           method: .post,
           headers: getHeader()) { (encodingResult) in
            switch encodingResult {
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    guard response.result.isSuccess else {
                        print("Error while fetching data: \(String(describing: response.result.error))")
                        completion(JSON.null, false)
                        return
                    }
                    
                    if let result = response.result.value {
                        print("******************** ITEM_REGISTER **********************")
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
    func itemRegister(params: Parameters, completion: @escaping (JSON, Bool) -> Void) {
        Alamofire.request(API.ITEM_REGISTER, method: .post, parameters: params, headers: getHeader()).responseJSON { (response) in
            guard response.result.isSuccess else {
                print("Error while fetching data: \(String(describing: response.result.error))")
                completion(JSON.null, false)
                return
            }
            
            if let result = response.result.value {
                print("******************** ITEM_REGISTER **********************")
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
     "id" : 34
     */
    func itemDelete(params: Parameters, completion: @escaping (JSON, Bool) -> Void) {
        Alamofire.request(API.ITEM_DELETE, method: .post, parameters: params, headers: getHeader()).responseJSON { (response) in
            guard response.result.isSuccess else {
                print("Error while fetching data: \(String(describing: response.result.error))")
                completion(JSON.null, false)
                return
            }
            
            if let result = response.result.value {
                //print("******************** ITEM_DELETE **********************")
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
     "id" : 34
     */
    func itemActive(params: Parameters, completion: @escaping (JSON, Bool) -> Void) {
        Alamofire.request(API.ITEM_ACTIVE, method: .post, parameters: params, headers: getHeader()).responseJSON { (response) in
            guard response.result.isSuccess else {
                print("Error while fetching data: \(String(describing: response.result.error))")
                completion(JSON.null, false)
                return
            }
            
            if let result = response.result.value {
                print("******************** ITEM_ACTIVE **********************")
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
     "id" : 34
     */
    func itemInactive(params: Parameters, completion: @escaping (JSON, Bool) -> Void) {
        Alamofire.request(API.ITEM_INACTIVE, method: .post, parameters: params, headers: getHeader()).responseJSON { (response) in
            guard response.result.isSuccess else {
                print("Error while fetching data: \(String(describing: response.result.error))")
                completion(JSON.null, false)
                return
            }
            
            if let result = response.result.value {
                print("******************** ITEM_INACTIVE **********************")
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
    
    /*func itemChange(images: [UIImage], params: Parameters, completion: @escaping (JSON, Bool) -> Void) {
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            for image in images {
                let imgData = UIImageJPEGRepresentation(image, 0.3)
                if let imageData = imgData {
                    let width = Int(image.size.width)
                    let height = Int(image.size.height)
                    let fileName = "\(width)x\(height).jpg"
                    print("File Name...", fileName)
                    
                    multipartFormData.append(imageData, withName: "item_images[]", fileName: fileName, mimeType: "image/jpeg")
                }
            }
            for (key, value) in params {
                if value is String {
                    multipartFormData.append((value as AnyObject).data(using: String.Encoding.utf8.rawValue)!, withName: key)
                } else if value is Int64 {
                    var data = value as! Int64
                    let int64Data = Data(bytes: &data,
                                         count: MemoryLayout.size(ofValue: data))
                    multipartFormData.append(int64Data, withName: key)
                } else if value is Int {
                    var data = value as! Int
                    let intData = Data(bytes: &data,
                                       count: MemoryLayout.size(ofValue: data))
                    multipartFormData.append(intData, withName: key)
                }
            }
        }, to: API.ITEM_CHANGE,
           method: .post,
           headers: getHeader()) { (encodingResult) in
            switch encodingResult {
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    guard response.result.isSuccess else {
                        print("Error while fetching data: \(String(describing: response.result.error))")
                        completion(JSON.null, false)
                        return
                    }
                    
                    if let result = response.result.value {
                        print("******************** ITEM_CHANGE **********************")
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
    func itemChange(params: Parameters, completion: @escaping (JSON, Bool) -> Void) {
        Alamofire.request(API.ITEM_CHANGE, method: .post, parameters: params, headers: getHeader()).responseJSON { (response) in
            guard response.result.isSuccess else {
                print("Error while fetching data: \(String(describing: response.result.error))")
                completion(JSON.null, false)
                return
            }
            
            if let result = response.result.value {
                print("******************** ITEM_CHANGE **********************")
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
    
    
    
    /*func storeChange(storeImage: UIImage?, licenseImage: UIImage?, images: [UIImage]?, params: Parameters, completion: @escaping (JSON, Bool) -> Void) {
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            if let storeImages = images {
                for image in storeImages {
                    let imgData = UIImageJPEGRepresentation(image, 0.3)
                    if let imageData = imgData {
                        let width = Int(image.size.width)
                        let height = Int(image.size.height)
                        let fileName = "\(width)x\(height).jpg"
                        
                        multipartFormData.append(imageData, withName: "store_images[]", fileName: fileName, mimeType: "image/jpeg")
                    }
                }
            }
            
            if storeImage != nil {
                let storeImageData = UIImageJPEGRepresentation(storeImage!, 0.3)
                if let imageData = storeImageData {
                    let width = Int(storeImage!.size.width)
                    let height = Int(storeImage!.size.height)
                    let fileName = "\(width)x\(height).jpg"
                    
                    multipartFormData.append(imageData, withName: "store_image", fileName: fileName, mimeType: "image/jpeg")
                }
            }
            
            if licenseImage != nil {
                let licenseImageData = UIImageJPEGRepresentation(licenseImage!, 0.3)
                if let imageData = licenseImageData {
                    let width = Int(licenseImage!.size.width)
                    let height = Int(licenseImage!.size.height)
                    let fileName = "\(width)x\(height).jpg"
                    
                    multipartFormData.append(imageData, withName: "license_image", fileName: fileName, mimeType: "image/jpeg")
                }
            }
            
            for (key, value) in params {
                if value is String {
                    multipartFormData.append((value as AnyObject).data(using: String.Encoding.utf8.rawValue)!, withName: key)
                } else if value is Int64 {
                    var data = value as! Int64
                    let int64Data = Data(bytes: &data,
                                         count: MemoryLayout.size(ofValue: data))
                    multipartFormData.append(int64Data, withName: key)
                } else if value is Int {
                    var data = value as! Int
                    let intData = Data(bytes: &data,
                                       count: MemoryLayout.size(ofValue: data))
                    multipartFormData.append(intData, withName: key)
                }
            }
        }, to: API.STORE_CHANGE,
           method: .post,
           headers: getHeader()) { (encodingResult) in
            switch encodingResult {
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    guard response.result.isSuccess else {
                        print("Error while fetching data: \(String(describing: response.result.error))")
                        completion(JSON.null, false)
                        return
                    }
                    
                    if let result = response.result.value {
                        print("******************** STORE_CHANGE **********************")
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
    func storeChange(params: Parameters, completion: @escaping (JSON, Bool) -> Void) {
        Alamofire.request(API.STORE_CHANGE, method: .post, parameters: params, headers: getHeader()).responseJSON { (response) in
            guard response.result.isSuccess else {
                print("Error while fetching data: \(String(describing: response.result.error))")
                completion(JSON.null, false)
                return
            }
            
            if let result = response.result.value {
                //print("******************** STORE_CHANGE **********************")
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
    
    
    func ticketList(page: Int, completion: @escaping (JSON, Bool) -> Void) {
        let url = String(format: API.TICKET_LIST, "\(page)")
        Alamofire.request(url, method: .post, headers: getHeader()).responseJSON { (response) in
            guard response.result.isSuccess else {
                print("Error while fetching data: \(String(describing: response.result.error))")
                completion(JSON.null, false)
                return
            }
            
            if let result = response.result.value {
                //print("******************** TICKET_LIST **********************")
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
     "content" : "eckjkm km"
     */
    func ticketCreate(params: Parameters, completion: @escaping (JSON, Bool) -> Void) {
        Alamofire.request(API.TICKET_CREATE, method: .post, parameters: params, headers: getHeader()).responseJSON { (response) in
            guard response.result.isSuccess else {
                print("Error while fetching data: \(String(describing: response.result.error))")
                completion(JSON.null, false)
                return
            }
            
            if let result = response.result.value {
                //print("******************** TICKET_CREATE **********************")
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
     "id" : 23
     */
    func ticketDelete(params: Parameters, completion: @escaping (JSON, Bool) -> Void) {
        Alamofire.request(API.TICKET_DELETE, method: .post, parameters: params, headers: getHeader()).responseJSON { (response) in
            guard response.result.isSuccess else {
                print("Error while fetching data: \(String(describing: response.result.error))")
                completion(JSON.null, false)
                return
            }
            
            if let result = response.result.value {
                //print("******************** TICKET_DELETE **********************")
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
     "id" : 23
     */
    func ticketMessageGet(params: Parameters, completion: @escaping (JSON, Bool) -> Void) {
        Alamofire.request(API.TICKET_MESSAGE_GET, method: .post, parameters: params, headers: getHeader()).responseJSON { (response) in
            guard response.result.isSuccess else {
                print("Error while fetching data: \(String(describing: response.result.error))")
                completion(JSON.null, false)
                return
            }
            
            if let result = response.result.value {
                //print("******************** TICKET_MESSAGE_GET **********************")
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
    
    func ticketMessageSend(params: Parameters, completion: @escaping (JSON, Bool) -> Void) {
        Alamofire.request(API.TICKET_MESSAGE_SEND, method: .post, parameters: params, headers: getHeader()).responseJSON { (response) in
            guard response.result.isSuccess else {
                print("Error while fetching data: \(String(describing: response.result.error))")
                completion(JSON.null, false)
                return
            }
            
            if let result = response.result.value {
                //print("******************** TICKET_MESSAGE_SEND **********************")
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
     'amount' => 'required|numeric|min:50|max:2000',
     'currency' => 'required|integer|min:1|max:2',
     'type' => 'required|boolean',
     */
    func paymentCreate(params: Parameters, completion: @escaping (JSON, Bool) -> Void) {
        Alamofire.request(API.PAYMENT_CREATE, method: .post, parameters: params, headers: getHeader()).responseJSON { (response) in
            guard response.result.isSuccess else {
                print("Error while fetching data: \(String(describing: response.result.error))")
                completion(JSON.null, false)
                return
            }
            
            if let result = response.result.value {
                print("******************** PAYMENT_CREATE **********************")
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
     'type' => 'boolean',
     */
    func paymentList(page: Int, params: Parameters, completion: @escaping (JSON, Bool) -> Void) {
        let url = String(format: API.PAYMENT_LIST, "\(page)")
        Alamofire.request(url, method: .post, parameters: params, headers: getHeader()).responseJSON { (response) in
            guard response.result.isSuccess else {
                print("Error while fetching data: \(String(describing: response.result.error))")
                completion(JSON.null, false)
                return
            }
            
            if let result = response.result.value {
                print("******************** PAYMENT_LIST **********************")
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
    
    
    func orderList(page: Int, params: Parameters, completion: @escaping (JSON, Bool) -> Void) {
        let url = String(format: API.ORDER_LIST, "\(page)")
        Alamofire.request(url, method: .post, parameters: params, headers: getHeader()).responseJSON { (response) in
            guard response.result.isSuccess else {
                print("Error while fetching data: \(String(describing: response.result.error))")
                completion(JSON.null, false)
                return
            }
            
            if let result = response.result.value {
                print("******************** ORDER_LIST **********************")
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
     "id" : 3 <- degree id
     */
    func profileDegreeUpdate(params: Parameters, completion: @escaping (JSON, Bool) -> Void) {
        Alamofire.request(API.PROFILE_DEGREE_UPDATE, method: .post, parameters: params, headers: getHeader()).responseJSON { (response) in
            guard response.result.isSuccess else {
                print("Error while fetching data: \(String(describing: response.result.error))")
                completion(JSON.null, false)
                return
            }
            
            if let result = response.result.value {
                //print("******************** PROFILE_DEGREE_UPDATE **********************")
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
     'items' => 'required|string|min:10',
     'user_name' => 'required|string|min:6|max:255',
     'address' => 'required|string|min:6|max:255',
     'phone_number' => 'required|string|regex:/(1)[0-9]{10}/',
     'payment' => 'required|integer',
     */
    func orderCreate(params: Parameters, completion: @escaping (JSON, Bool) -> Void) {
        Alamofire.request(API.ORDER_CREATE, method: .post, parameters: params, headers: getHeader()).responseJSON { (response) in
            guard response.result.isSuccess else {
                print("Error while fetching data: \(String(describing: response.result.error))")
                completion(JSON.null, false)
                return
            }
            
            if let result = response.result.value {
                print("******************** ORDER_CREATE **********************")
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
    
    func paymentAddress(completion: @escaping (JSON, Bool) -> Void) {
        Alamofire.request(API.PAYMENT_ADDRESS, method: .post, headers: getHeader()).responseJSON { (response) in
            guard response.result.isSuccess else {
                print("Error while fetching data: \(String(describing: response.result.error))")
                completion(JSON.null, false)
                return
            }
            
            if let result = response.result.value {
                print("******************** PAYMENT_ADDRESS **********************")
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
    
    func orderDetail(params: Parameters, completion: @escaping (JSON, Bool) -> Void) {
        Alamofire.request(API.ORDER_DETAIL, method: .post, parameters: params, headers: getHeader()).responseJSON { (response) in
            guard response.result.isSuccess else {
                print("Error while fetching data: \(String(describing: response.result.error))")
                completion(JSON.null, false)
                return
            }
            
            if let result = response.result.value {
                print("******************** ORDER_DETAIL **********************")
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
    
    func orderDelete(params: Parameters, completion: @escaping (JSON, Bool) -> Void) {
        Alamofire.request(API.ORDER_DELETE, method: .post, parameters: params, headers: getHeader()).responseJSON { (response) in
            guard response.result.isSuccess else {
                print("Error while fetching data: \(String(describing: response.result.error))")
                completion(JSON.null, false)
                return
            }
            
            if let result = response.result.value {
                print("******************** ORDER_DELETE **********************")
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
     current_password:
     payment_password:
     */
    func paymentPasswordChange(params: Parameters, completion: @escaping (JSON, Bool) -> Void) {
        Alamofire.request(API.PAYMENT_PASSWORD_CHANGE, method: .post, parameters: params, headers: getHeader()).responseJSON { (response) in
            guard response.result.isSuccess else {
                print("Error while fetching data: \(String(describing: response.result.error))")
                completion(JSON.null, false)
                return
            }
            
            if let result = response.result.value {
                print("******************** PAYMENT_PASSWORD_CHANGE **********************")
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
     payment_password:
     */
    func paymentPasswordVerify(params: Parameters, completion: @escaping (JSON, Bool) -> Void) {
        Alamofire.request(API.PAYMENT_PASSWORD_VERIFY, method: .post, parameters: params, headers: getHeader()).responseJSON { (response) in
            guard response.result.isSuccess else {
                print("Error while fetching data: \(String(describing: response.result.error))")
                completion(JSON.null, false)
                return
            }
            
            if let result = response.result.value {
                print("******************** PAYMENT_PASSWORD_VERIFY **********************")
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
     'id' => 'required|integer|exists:orders',
     'status' => 'required|integer|min:0|max:3',
     'receipt' => 'required_if:status:3|integer|min:0|max:3',
     */
    func orderStatusChange(params: Parameters, completion: @escaping (JSON, Bool) -> Void) {
        Alamofire.request(API.ORDER_STATUS_CHANGE, method: .post, parameters: params, headers: getHeader()).responseJSON { (response) in
            guard response.result.isSuccess else {
                print("Error while fetching data: \(String(describing: response.result.error))")
                completion(JSON.null, false)
                return
            }
            
            if let result = response.result.value {
                print("******************** ORDER_STATUS_CHANGE **********************")
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
    
    func profileDegree(completion: @escaping (JSON, Bool) -> Void) {
        Alamofire.request(API.PROFILE_DEGREE, method: .post, headers: getHeader()).responseJSON { (response) in
            guard response.result.isSuccess else {
                print("Error while fetching data: \(String(describing: response.result.error))")
                completion(JSON.null, false)
                return
            }
            
            if let result = response.result.value {
                print("******************** PROFILE_DEGREE **********************")
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
    
    func paymentDetail(params: Parameters, completion: @escaping (JSON, Bool) -> Void) {
        Alamofire.request(API.PAYMENT_DETAIL, method: .post, parameters: params, headers: getHeader()).responseJSON { (response) in
            guard response.result.isSuccess else {
                print("Error while fetching data: \(String(describing: response.result.error))")
                completion(JSON.null, false)
                return
            }
            
            if let result = response.result.value {
                print("******************** PAYMENT_DETAIL **********************")
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
    
    func configRates(completion: @escaping (JSON, Bool) -> Void) {
        Alamofire.request(API.CONFIG_RATES, method: .post, headers: getHeader()).responseJSON { (response) in
            guard response.result.isSuccess else {
                print("Error while fetching data: \(String(describing: response.result.error))")
                completion(JSON.null, false)
                return
            }
            
            if let result = response.result.value {
                print("******************** CONFIG_RATE **********************")
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
     currency 1: pi, 2: yen 3: point
     type: true : send, false: receive
     */
    func transactionList(page: Int, params: Parameters, completion: @escaping (JSON, Bool) -> Void) {
        let url = String(format: API.TRANSACTION_LIST, "\(page)")
        
        Alamofire.request(url, method: .post, parameters: params, headers: getHeader()).responseJSON { (response) in
            guard response.result.isSuccess else {
                print("Error while fetching data: \(String(describing: response.result.error))")
                completion(JSON.null, false)
                return
            }
            
            if let result = response.result.value {
                print("******************** TRANSACTION_LIST **********************")
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
     amount:
     */
    func paymentExchange(params: Parameters, completion: @escaping (JSON, Bool) -> Void) {
        Alamofire.request(API.PAYMENT_EXCHANGE, method: .post, parameters: params, headers: getHeader()).responseJSON { (response) in
            guard response.result.isSuccess else {
                print("Error while fetching data: \(String(describing: response.result.error))")
                completion(JSON.null, false)
                return
            }
            
            if let result = response.result.value {
                print("******************** PAYMENT_EXCHANGE **********************")
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
     type: true: seller, false : buyer
     */
    func restitutionList(page: Int, params: Parameters, completion: @escaping (JSON, Bool) -> Void) {
        let url = String(format: API.RESTITUTION_LIST, "\(page)")
        Alamofire.request(url, method: .post, parameters: params, headers: getHeader()).responseJSON { (response) in
            guard response.result.isSuccess else {
                print("Error while fetching data: \(String(describing: response.result.error))")
                completion(JSON.null, false)
                return
            }
            
            if let result = response.result.value {
                print("******************** RESTITUTION_LIST **********************")
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
     restitution_id
     */
    func restitutionTransactionList(page: Int, params: Parameters, completion: @escaping (JSON, Bool) -> Void) {
        let url = String(format: API.RESTITUTION_TRANSACTION_LIST, "\(page)")
        Alamofire.request(url, method: .post, parameters: params, headers: getHeader()).responseJSON { (response) in
            guard response.result.isSuccess else {
                print("Error while fetching data: \(String(describing: response.result.error))")
                completion(JSON.null, false)
                return
            }
            
            if let result = response.result.value {
                print("******************** RESTITUTION_TRANSACTION_LIST **********************")
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
     token:
     sound:
     */
    func deviceSound(params: Parameters, completion: @escaping (JSON, Bool) -> Void) {
        Alamofire.request(API.DEVICE_SOUND, method: .post, parameters: params, headers: getHeader()).responseJSON { (response) in
            guard response.result.isSuccess else {
                print("Error while fetching data: \(String(describing: response.result.error))")
                completion(JSON.null, false)
                return
            }
            
            if let result = response.result.value {
                print("******************** DEVICE_SOUND **********************")
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
    
    func systemInfo(completion: @escaping (JSON, Bool) -> Void) {
        Alamofire.request(API.SYSTEM_INFO, method: .post, headers: getHeader()).responseJSON { (response) in
            guard response.result.isSuccess else {
                print("Error while fetching data: \(String(describing: response.result.error))")
                completion(JSON.null, false)
                return
            }
            
            if let result = response.result.value {
                print("******************** SYSTEM_INFO **********************")
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
    
    func phoneNumberUpdate(params: Parameters, completion: @escaping (JSON, Bool) -> Void) {
        Alamofire.request(API.PHONENUMBER_UPDATE, method: .post, parameters: params, headers: getHeader()).responseJSON { (response) in
            guard response.result.isSuccess else {
                print("Error while fetching data: \(String(describing: response.result.error))")
                completion(JSON.null, false)
                return
            }
            
            print("$$$$$ response $$$$$$$")
            print(response)
            
            if let result = response.result.value {
                print("******************** PHONENUMBER_UPDATE **********************")
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
    
    
    func liveMine(page: Int, completion: @escaping (JSON, Bool) -> Void) {
        let url = String(format: API.LIVE_MINE, "\(page)")
        Alamofire.request(url, method: .post, headers: getHeader()).responseJSON { (response) in
            guard response.result.isSuccess else {
                print("Error while fetching data: \(String(describing: response.result.error))")
                completion(JSON.null, false)
                return
            }
            
            if let result = response.result.value {
                print("******************** LIVE_MINE **********************")
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
    
    func liveActive(params: Parameters, completion: @escaping (JSON, Bool) -> Void) {
        Alamofire.request(API.LIVE_ACTIVE, method: .post, parameters: params, headers: getHeader()).responseJSON { (response) in
            guard response.result.isSuccess else {
                print("Error while fetching data: \(String(describing: response.result.error))")
                completion(JSON.null, false)
                return
            }
            
            if let result = response.result.value {
                print("******************** LIVE_ACTIVE **********************")
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
    
    func liveInactive(params: Parameters, completion: @escaping (JSON, Bool) -> Void) {
        Alamofire.request(API.LIVE_INACTIVE, method: .post, parameters: params, headers: getHeader()).responseJSON { (response) in
            guard response.result.isSuccess else {
                print("Error while fetching data: \(String(describing: response.result.error))")
                completion(JSON.null, false)
                return
            }
            
            if let result = response.result.value {
                print("******************** LIVE_INACTIVE **********************")
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
    
    
    func liveDelete(params: Parameters, completion: @escaping (JSON, Bool) -> Void) {
        Alamofire.request(API.LIVE_DELETE, method: .post, parameters: params, headers: getHeader()).responseJSON { (response) in
            guard response.result.isSuccess else {
                print("Error while fetching data: \(String(describing: response.result.error))")
                completion(JSON.null, false)
                return
            }
            
            if let result = response.result.value {
                print("******************** LIVE_DELETE **********************")
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
    
    
    func contactList(completion: @escaping (JSON, Bool) -> Void) {
        Alamofire.request(API.CONTACT_LIST, method: .post, headers: getHeader()).responseJSON { (response) in
            guard response.result.isSuccess else {
                print("Error while fetching data: \(String(describing: response.result.error))")
                completion(JSON.null, false)
                return
            }
            
            if let result = response.result.value {
                print("******************** CONTACT_LIST **********************")
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
    
    func contactUpdate(params: Parameters, completion: @escaping (JSON, Bool) -> Void) {
        Alamofire.request(API.CONTACT_UPDATE, method: .post, parameters: params, headers: getHeader()).responseJSON { (response) in
            guard response.result.isSuccess else {
                print("Error while fetching data: \(String(describing: response.result.error))")
                completion(JSON.null, false)
                return
            }
            
            if let result = response.result.value {
                print("******************** CONTACT_UPDATE **********************")
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
    
    func contactAdd(params: Parameters, completion: @escaping (JSON, Bool) -> Void) {
        Alamofire.request(API.CONTACT_ADD, method: .post, parameters: params, headers: getHeader()).responseJSON { (response) in
            guard response.result.isSuccess else {
                print("Error while fetching data: \(String(describing: response.result.error))")
                completion(JSON.null, false)
                return
            }
            
            if let result = response.result.value {
                print("******************** CONTACT_ADD **********************")
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
    
    func contactDelete(params: Parameters, completion: @escaping (JSON, Bool) -> Void) {
        Alamofire.request(API.CONTACT_DELETE, method: .post, parameters: params, headers: getHeader()).responseJSON { (response) in
            guard response.result.isSuccess else {
                print("Error while fetching data: \(String(describing: response.result.error))")
                completion(JSON.null, false)
                return
            }
            
            if let result = response.result.value {
                print("******************** CONTACT_DELETE **********************")
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
    
    func contactDefault(params: Parameters, completion: @escaping (JSON, Bool) -> Void) {
        Alamofire.request(API.CONTACT_DEFAULT, method: .post, parameters: params, headers: getHeader()).responseJSON { (response) in
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
    
    // set buy Level info
    func purchaseLevel(params: Parameters, completion: @escaping (NSDictionary, Bool) -> Void) {
        Alamofire.request(API.PURCHASE_LEVEL, method: .post, parameters: params, headers: getHeader()).responseJSON { response in
            print(response)
            if response.result.isSuccess {
                print("--------- Purchase Level ---------")
                print(response.result.value as! NSDictionary)
                
                completion(response.result.value as! NSDictionary, true)
                return
                
            } else {
                completion(NSDictionary(), false)
                return
            }
            
        }
    }
    
    // get first invites
    func getInvites(params: Parameters, completion: @escaping (NSDictionary, Bool) -> Void) {
        Alamofire.request(API.GET_INVITES, method: .post, parameters: params).responseJSON { response in
            if response.result.isSuccess {
                completion(response.result.value as! NSDictionary, true)
                return
                
            } else {
                completion(NSDictionary(), false)
                return
            }
            
        }
    }
    
    // get second invites
    func getSeconds(params: Parameters, completion: @escaping (NSDictionary, Bool) -> Void) {
        Alamofire.request(API.GET_SECOND, method: .post, parameters: params).responseJSON { response in
            if response.result.isSuccess {
                completion(response.result.value as! NSDictionary, true)
                return
                
            } else {
                completion(NSDictionary(), false)
                return
            }
            
        }
    }
    
    // get detail all
    func getDetailAll(params: Parameters, completion: @escaping (NSDictionary, Bool) -> Void) {
        Alamofire.request(API.GET_DETAILALL, method: .post, parameters: params).responseJSON { response in
            if response.result.isSuccess {
                completion(response.result.value as! NSDictionary, true)
                return
                
            } else {
                completion(NSDictionary(), false)
                return
            }
            
        }
    }
    
    // get detail all
    func getDetail(params: Parameters, completion: @escaping (NSDictionary, Bool) -> Void) {
        Alamofire.request(API.GET_DETAIL, method: .post, parameters: params).responseJSON { response in
            if response.result.isSuccess {
                completion(response.result.value as! NSDictionary, true)
                return
                
            } else {
                completion(NSDictionary(), false)
                return
            }
            
        }
    }
    
    // get buy Level info
    func getBuyLevelInfo(params: Parameters, completion: @escaping (NSDictionary, Bool) -> Void) {
        Alamofire.request(API.GET_SETTING, method: .post, parameters: params).responseJSON { response in
            if response.result.isSuccess {
                completion(response.result.value as! NSDictionary, true)
                return
                
            } else {
                completion(NSDictionary(), false)
                return
            }
            
        }
    }
    
    // get alipay order
    func getAlipayOrder(params: Parameters, completion: @escaping (NSDictionary, Bool) -> Void) {
        Alamofire.request(API.ALIPAY_ORDER, method: .post, parameters: params, headers: getHeader()).responseJSON { response in
            //print(response.result)
            if response.result.isSuccess {
                completion(response.result.value as! NSDictionary, true)
                return
                
            } else {
                completion(NSDictionary(), false)
                return
            }
            
        }
    }
    
    // Wechat, Alipay order
    func wechatOrderCreate(params: Parameters, completion: @escaping (NSDictionary, Bool) -> Void) {
        Alamofire.request(API.WECHAT_ORDER, method: .post, parameters: params, headers: getHeader()).responseJSON { response in
            //print(response.result)
            if response.result.isSuccess {
                completion(response.result.value as! NSDictionary, true)
                return
                
            } else {
                completion(NSDictionary(), false)
                return
            }
            
        }
    }
    
    func setByCurrency(params: Parameters, completion: @escaping (NSDictionary, Bool) -> Void) {
        Alamofire.request(API.SET_BY_CURRENCY, method: .post, parameters: params, headers: getHeader()).responseJSON { response in
            //print(response.result)
            if response.result.isSuccess {
                completion(response.result.value as! NSDictionary, true)
                return
                
            } else {
                completion(NSDictionary(), false)
                return
            }
            
        }
    }
    
    // MARK: - APIs for QR Code payment (2018-12-06)
    // get qr code information
    func getQRCodeInformation(strUrl: String, completion: @escaping (NSDictionary, Bool) -> Void) {
        Alamofire.request(API.BASE_URL + strUrl, method: .get, headers: getHeader()).responseJSON { response in
            if response.result.isSuccess {
                completion(response.result.value as! NSDictionary, true)
                return
                
            } else {
                completion(NSDictionary(), false)
                return
            }
            
        }
    }
    
    // create qr code payment
    func createQRCodePay(params: Parameters, completion: @escaping (NSDictionary, Bool) -> Void) {
        Alamofire.request(API.CREATE_QRCODE_PAYMENT, method: .post, parameters: params, headers: getHeader()).responseJSON { response in
            if response.result.isSuccess {
                completion(response.result.value as! NSDictionary, true)
                return
                
            } else {
                completion(NSDictionary(), false)
                return
            }
            
        }
    }
    
    // call after qr payment success
    func paymentQRSuccess(params: Parameters, completion: @escaping (NSDictionary, Bool) -> Void) {
        Alamofire.request(API.QRCODE_PAYMENT_SUCCESS, method: .post, parameters: params, headers: getHeader()).responseJSON { response in
            if response.result.isSuccess {
                print(response)
                completion(response.result.value as! NSDictionary, true)
                return
                
            } else {
                completion(NSDictionary(), false)
                return
            }
            
        }
    }
}









