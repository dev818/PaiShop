
import Foundation
import Alamofire
import SwiftyJSON

class HomeAPI {
    static let shared = HomeAPI()
    
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
    
    
    func itemPromotions(completion: @escaping (JSON, Bool) -> Void) {
        Alamofire.request(API.ITEM_PROMOTIONS, method: .post, headers: headers).responseJSON { (response) in
            guard response.result.isSuccess else {
                print("Error while fetching data: \(String(describing: response.result.error))")
                completion(JSON.null, false)
                return
            }
            
            if let result = response.result.value {
                //print("******************** ITEM_PROMOTIONS **********************")
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
    
    
    func categoryRoot(completion: @escaping (JSON, Bool) -> Void) {
        Alamofire.request(API.CATEGORY_ROOT, method: .post, headers: headers).responseJSON { (response) in
            guard response.result.isSuccess else {
                print("Error while fetching data: \(String(describing: response.result.error))")
                completion(JSON.null, false)
                return
            }
            
            if let result = response.result.value {
                //print("******************** CATEGORY_ROOT **********************")
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
    
    
    func itemHome(page: Int, completion: @escaping (JSON, Bool) -> Void) {
        let url = String(format: API.HOME_ITEMS, "\(page)")
        //print(url)
        var header = headers
        if UserInstance.isLogin {
            header = getHeader()
        }
        Alamofire.request(url, method: .post, headers: header).responseJSON { (response) in
            guard response.result.isSuccess else {
                print("Error while fetching data: \(String(describing: response.result.error))")
                completion(JSON.null, false)
                return
            }
            
            if let result = response.result.value {
                //print("******************** HOME_ITEMS **********************")
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
    
    func itemHomeWithCity(page: Int, cityName: String, completion: @escaping (JSON, Bool) -> Void) {
        let url = String(format: API.HOME_ITEMS, "\(page)")
        //print(url)
        let params: Parameters = [
            "city" : cityName
        ]
        Alamofire.request(url, method: .post, parameters: params, headers: headers).responseJSON { (response) in
            guard response.result.isSuccess else {
                print("Error while fetching data: \(String(describing: response.result.error))")
                completion(JSON.null, false)
                return
            }
            
            if let result = response.result.value {
                //print("******************** HOME_ITEMS **********************")
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
    
    func itemCategory(page: Int, categoryId: Int64, completion: @escaping (JSON, Bool) -> Void) {
        let url = String(format: API.ITEM_CATEGORY, "\(page)")
        let params: Parameters = [
            "id": categoryId
        ]
        var header = headers
        if UserInstance.isLogin {
            header = getHeader()
        }
        Alamofire.request(url, method: .post, parameters: params, headers: header).responseJSON { (response) in
            guard response.result.isSuccess else {
                print("Error while fetching data: \(String(describing: response.result.error))")
                completion(JSON.null, false)
                return
            }
            
            if let result = response.result.value {
                //print("******************** ITEM_CATEGORY **********************")
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
    
    func itemCity(page: Int, cityId: Int, completion: @escaping (JSON, Bool) -> Void) {
        let url = String(format: API.ITEM_CITY, "\(page)")
        let params: Parameters = [
            "id": cityId,
        ]
        var header = headers
        if UserInstance.isLogin {
            //params["user_id"] = UserInstance.userId!
            header = getHeader()
        }
        Alamofire.request(url, method: .post, parameters: params, headers: header).responseJSON { (response) in
            guard response.result.isSuccess else {
                print("Error while fetching data: \(String(describing: response.result.error))")
                completion(JSON.null, false)
                return
            }
            
            if let result = response.result.value {
                print("******************** ITEM_CITY **********************")
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
    
    func itemDetail(itemId: Int64, completion: @escaping (JSON, Bool) -> Void) {
        let params: Parameters = [
            "id": itemId
        ]
        var header = headers
        if UserInstance.isLogin {
            header = getHeader()
        }
        Alamofire.request(API.ITEM_DETAIL, method: .post, parameters: params, headers: header).responseJSON { (response) in
            guard response.result.isSuccess else {
                print("Error while fetching data: \(String(describing: response.result.error))")
                completion(JSON.null, false)
                return
            }
            
            if let result = response.result.value {
                //print("******************** ITEM_DETAIL **********************")
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
    
    
    func storeDetail(storeId: Int64, completion: @escaping (JSON, Bool) -> Void) {
        let params: Parameters = [
            "id": storeId
        ]
        var header = headers
        if UserInstance.isLogin {
            header = getHeader()
        }
        Alamofire.request(API.STORE_DETAIL, method: .post, parameters: params, headers: header).responseJSON { (response) in
            guard response.result.isSuccess else {
                print("Error while fetching data: \(String(describing: response.result.error))")
                completion(JSON.null, false)
                return
            }
            
            if let result = response.result.value {
                print("******************** STORE_DETAIL **********************")
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
    
    func itemStore(page:Int, storeId: Int64, completion: @escaping (JSON, Bool) -> Void) {
        let url = String(format: API.ITEM_STORE, "\(page)")
        let params: Parameters = [
            "id": storeId
        ]
        var header = headers
        if UserInstance.isLogin {
            header = getHeader()
        }
        Alamofire.request(url, method: .post, parameters: params, headers: header).responseJSON { (response) in
            guard response.result.isSuccess else {
                print("Error while fetching data: \(String(describing: response.result.error))")
                completion(JSON.null, false)
                return
            }
            
            if let result = response.result.value {
                //print("******************** ITEM_STORE **********************")
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
    
    func cityRoot(completion: @escaping (JSON, Bool) -> Void) {
        Alamofire.request(API.CITY_ROOT, method: .post, headers: headers).responseJSON { (response) in
            guard response.result.isSuccess else {
                print("Error while fetching data: \(String(describing: response.result.error))")
                completion(JSON.null, false)
                return
            }
            
            if let result = response.result.value {
                //print("******************** CITY_ROOT **********************")
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
     "id" : 3
     */
    func cityChildren(params: Parameters, completion: @escaping (JSON, Bool) -> Void) {
        Alamofire.request(API.CITY_CHILDREN, method: .post, parameters: params, headers: headers).responseJSON { (response) in
            guard response.result.isSuccess else {
                print("Error while fetching data: \(String(describing: response.result.error))")
                completion(JSON.null, false)
                return
            }
            
            if let result = response.result.value {
                //print("******************** CITY_CHILDREN **********************")
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
     "id" : "487343434dd3993"
     */
    func commentDetail(params: Parameters, completion: @escaping (JSON, Bool) -> Void) {
        Alamofire.request(API.COMMENT_DETAIL, method: .post, parameters: params, headers: headers).responseJSON { (response) in
            guard response.result.isSuccess else {
                print("Error while fetching data: \(String(describing: response.result.error))")
                completion(JSON.null, false)
                return
            }
            
            if let result = response.result.value {
                //print("******************** COMMENT_DETAIL **********************")
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
     "text" : "Good Item"
     "rate" : 4
     */
    func commentAdd(params: Parameters, completion: @escaping (JSON, Bool) -> Void) {
        Alamofire.request(API.COMMENT_ADD, method: .post, parameters: params, headers: getHeader()).responseJSON { (response) in
            guard response.result.isSuccess else {
                print("Error while fetching data: \(String(describing: response.result.error))")
                completion(JSON.null, false)
                return
            }
            
            if let result = response.result.value {
                //print("******************** COMMENT_ADD **********************")
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
     "id" : 487523fdfsdf832
     "text" : "Good Item"
     "rate" : 4
     */
    func commentChange(params: Parameters, completion: @escaping (JSON, Bool) -> Void) {
        Alamofire.request(API.COMMENT_CHANGE, method: .post, parameters: params, headers: headers).responseJSON { (response) in
            guard response.result.isSuccess else {
                print("Error while fetching data: \(String(describing: response.result.error))")
                completion(JSON.null, false)
                return
            }
            
            if let result = response.result.value {
                //print("******************** COMMENT_CHANGE **********************")
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
     "id" : 487523fdfsdf832
     */
    func commentDelete(params: Parameters, completion: @escaping (JSON, Bool) -> Void) {
        Alamofire.request(API.COMMENT_DELETE, method: .post, parameters: params, headers: headers).responseJSON { (response) in
            guard response.result.isSuccess else {
                print("Error while fetching data: \(String(describing: response.result.error))")
                completion(JSON.null, false)
                return
            }
            
            if let result = response.result.value {
                //print("******************** COMMENT_DELETE **********************")
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
     "id" : 246
     */
    func commentItem(page:Int, params: Parameters, completion: @escaping (JSON, Bool) -> Void) {
        let url = String(format: API.COMMENT_ITEM, "\(page)")
        Alamofire.request(url, method: .post, parameters: params, headers: headers).responseJSON { (response) in
            guard response.result.isSuccess else {
                print("Error while fetching data: \(String(describing: response.result.error))")
                completion(JSON.null, false)
                return
            }
            
            if let result = response.result.value {
                //print("******************** COMMENT_ITEM **********************")
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
    
    /*func storeRegister(storeImage: UIImage, licenseImage: UIImage, images: [UIImage]?, params: Parameters, completion: @escaping (JSON, Bool) -> Void) {
        
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
            
            let storeImageData = UIImageJPEGRepresentation(storeImage, 0.3)
            if let imageData = storeImageData {
                let width = Int(storeImage.size.width)
                let height = Int(storeImage.size.height)
                let fileName = "\(width)x\(height).jpg"
                
                multipartFormData.append(imageData, withName: "store_image", fileName: fileName, mimeType: "image/jpeg")
            }
            
            let licenseImageData = UIImageJPEGRepresentation(licenseImage, 0.3)
            if let imageData = licenseImageData {
                let width = Int(licenseImage.size.width)
                let height = Int(licenseImage.size.height)
                let fileName = "\(width)x\(height).jpg"
                
                multipartFormData.append(imageData, withName: "license_image", fileName: fileName, mimeType: "image/jpeg")
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
        }, to: API.STORE_REGISTER,
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
                        print("******************** STORE_REGISTER **********************")
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
    func storeRegister(params: Parameters, completion: @escaping (JSON, Bool) -> Void) {
        Alamofire.request(API.STORE_REGISTER, method: .post, parameters: params, headers: getHeader()).responseJSON { (response) in
            guard response.result.isSuccess else {
                print("Error while fetching data: \(String(describing: response.result.error))")
                completion(JSON.null, false)
                return
            }
            
            if let result = response.result.value {
                //print("******************** STORE_REGISTER **********************")
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
     "keyword" : "he"
     */
    func itemSearch(page:Int, params: Parameters, completion: @escaping (JSON, Bool) -> Void) {
        let url = String(format: API.ITEM_SEARCH, "\(page)")
        var header = headers
        if UserInstance.isLogin {
            header = getHeader()
        }
        Alamofire.request(url, method: .post, parameters: params, headers: header).responseJSON { (response) in
            guard response.result.isSuccess else {
                print("Error while fetching data: \(String(describing: response.result.error))")
                completion(JSON.null, false)
                return
            }
            
            if let result = response.result.value {
                print("******************** ITEM_SEARCH **********************")
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
     "id" : 478
     */
    func itemLike(params: Parameters, completion: @escaping (JSON, Bool) -> Void) {
        Alamofire.request(API.ITEM_LIKE, method: .post, parameters: params, headers: getHeader()).responseJSON { (response) in
            guard response.result.isSuccess else {
                print("Error while fetching data: \(String(describing: response.result.error))")
                completion(JSON.null, false)
                return
            }
            
            if let result = response.result.value {
                print("******************** ITEM_LIKE **********************")
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
    
    
    func tokenCheck(completion: @escaping (JSON, Bool) -> Void) {
        Alamofire.request(API.TOKEN_CHECK, method: .post, headers: getHeader()).responseJSON { (response) in
            guard response.result.isSuccess else {
                print("Error while fetching data: \(String(describing: response.result.error))")
                completion(JSON.null, false)
                return
            }
            
            if let result = response.result.value {
                print("******************** TOKEN_CHECK **********************")
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
    
    func storeFavoriteAdd(params: Parameters, completion: @escaping (JSON, Bool) -> Void) {
        Alamofire.request(API.STORE_FAVORITE_ADD, method: .post, parameters: params, headers: getHeader()).responseJSON { (response) in
            guard response.result.isSuccess else {
                print("Error while fetching data: \(String(describing: response.result.error))")
                completion(JSON.null, false)
                return
            }
            
            if let result = response.result.value {
                //print("******************** STORE_FAVORITE_ADD **********************")
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
    
    func storeFavoriteDelete(params: Parameters, completion: @escaping (JSON, Bool) -> Void) {
        Alamofire.request(API.STORE_FAVORITE_DELETE, method: .post, parameters: params, headers: getHeader()).responseJSON { (response) in
            guard response.result.isSuccess else {
                print("Error while fetching data: \(String(describing: response.result.error))")
                completion(JSON.null, false)
                return
            }
            
            if let result = response.result.value {
                //print("******************** STORE_FAVORITE_DELETE **********************")
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
    
    func storeFavoriteList(page: Int, completion: @escaping (JSON, Bool) -> Void) {
        let url = String(format: API.STORE_FAVORITE_LIST, "\(page)")
        Alamofire.request(url, method: .post, headers: getHeader()).responseJSON { (response) in
            guard response.result.isSuccess else {
                print("Error while fetching data: \(String(describing: response.result.error))")
                completion(JSON.null, false)
                return
            }
            
            if let result = response.result.value {
                //print("******************** STORE_FAVORITE_LIST **********************")
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
    
    func notificationList(completion: @escaping (JSON, Bool) -> Void) {
        Alamofire.request(API.NOTIFICATION_LIST, method: .post, headers: headers).responseJSON { (response) in
            guard response.result.isSuccess else {
                print("Error while fetching data: \(String(describing: response.result.error))")
                completion(JSON.null, false)
                return
            }
            
            if let result = response.result.value {
                //print("******************** NOTIFICATION_LIST **********************")
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
    
    func degrees(completion: @escaping (JSON, Bool) -> Void) {
        Alamofire.request(API.DEGREES, method: .post, headers: headers).responseJSON { (response) in
            guard response.result.isSuccess else {
                print("Error while fetching data: \(String(describing: response.result.error))")
                completion(JSON.null, false)
                return
            }
            
            if let result = response.result.value {
                //print("******************** DEGREES **********************")
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
    
    
    func storeRecommend(completion: @escaping (JSON, Bool) -> Void) {
        Alamofire.request(API.STORE_RECOMMEND, method: .post, headers: headers).responseJSON { (response) in
            guard response.result.isSuccess else {
                print("Error while fetching data: \(String(describing: response.result.error))")
                completion(JSON.null, false)
                return
            }
            
            if let result = response.result.value {
                print("******************** STORE_RECOMMEND **********************")
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
    
    func itemRecommend(completion: @escaping (JSON, Bool) -> Void) {
        Alamofire.request(API.ITEM_RECOMMEND, method: .post, headers: headers).responseJSON { (response) in
            guard response.result.isSuccess else {
                print("Error while fetching data: \(String(describing: response.result.error))")
                completion(JSON.null, false)
                return
            }
            
            if let result = response.result.value {
                print("******************** ITEM_RECOMMEND **********************")
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
    
    func Recommends(completion: @escaping (JSON, Bool) -> Void) {
        Alamofire.request(API.RECOMMENDS, method: .post, headers: headers).responseJSON { (response) in
            guard response.result.isSuccess else {
                print("Error while fetching data: \(String(describing: response.result.error))")
                completion(JSON.null, false)
                return
            }
            
            if let result = response.result.value {
                print("******************** RECOMMENDS **********************")
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
    
    func itemFavoriteAdd(params: Parameters, completion: @escaping (JSON, Bool) -> Void) {
        Alamofire.request(API.ITEM_FAVORITE_ADD, method: .post, parameters: params, headers: getHeader()).responseJSON { (response) in
            guard response.result.isSuccess else {
                print("Error while fetching data: \(String(describing: response.result.error))")
                completion(JSON.null, false)
                return
            }
            
            if let result = response.result.value {
                //print("******************** ITEM_FAVORITE_ADD **********************")
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
    
    func itemFavoriteDelete(params: Parameters, completion: @escaping (JSON, Bool) -> Void) {
        Alamofire.request(API.ITEM_FAVORITE_DELETE, method: .post, parameters: params, headers: getHeader()).responseJSON { (response) in
            guard response.result.isSuccess else {
                print("Error while fetching data: \(String(describing: response.result.error))")
                completion(JSON.null, false)
                return
            }
            
            if let result = response.result.value {
                //print("******************** ITEM_FAVORITE_DELETE **********************")
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
    
    func itemFavoriteList(page: Int, completion: @escaping (JSON, Bool) -> Void) {
        let url = String(format: API.ITEM_FAVORITE_LIST, "\(page)")
        Alamofire.request(url, method: .post, headers: getHeader()).responseJSON { (response) in
            guard response.result.isSuccess else {
                print("Error while fetching data: \(String(describing: response.result.error))")
                completion(JSON.null, false)
                return
            }
            
            if let result = response.result.value {
                //print("******************** ITEM_FAVORITE_LIST **********************")
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
    
    func itemStoreBest(params: Parameters, completion: @escaping (JSON, Bool) -> Void) {
        Alamofire.request(API.ITEM_STORE_BEST, method: .post, parameters: params, headers: getHeader()).responseJSON { (response) in
            guard response.result.isSuccess else {
                print("Error while fetching data: \(String(describing: response.result.error))")
                completion(JSON.null, false)
                return
            }
            
            if let result = response.result.value {
                //print("******************** ITEM_STORE_BEST **********************")
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
















