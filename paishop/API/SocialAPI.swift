
import Foundation
import Alamofire
import SwiftyJSON

class SocialAPI {
    static let shared = SocialAPI()
    
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
    
    
    func chatAll(page: Int, completion: @escaping (JSON, Bool) -> Void) {
        let url = String(format: API.CHAT_ALL, "\(page)")
        //print(url)
        Alamofire.request(url, method: .post, headers: getHeader()).responseJSON { (response) in
            guard response.result.isSuccess else {
                print("Error while fetching data: \(String(describing: response.result.error))")
                completion(JSON.null, false)
                return
            }
            
            if let result = response.result.value {
                //print("******************** CHAT_ALL **********************")
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
    
    
    func chatList(page: Int, completion: @escaping (JSON, Bool) -> Void) {
        let url = String(format: API.CHAT_LIST, "\(page)")
        //print(url)
        Alamofire.request(url, method: .post, headers: getHeader()).responseJSON { (response) in
            guard response.result.isSuccess else {
                print("Error while fetching data: \(String(describing: response.result.error))")
                completion(JSON.null, false)
                return
            }
            
            if let result = response.result.value {
                //print("******************** CHAT_LIST **********************")
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
     "id" : chatListModel.id
    */
    func chatMessageGet(page: Int, params: Parameters, completion: @escaping (JSON, Bool) -> Void) {
        let url = String(format: API.CHAT_MESSAGE_GET, "\(page)")
        //print(url)
        Alamofire.request(url, method: .post, parameters: params, headers: getHeader()).responseJSON { (response) in
            guard response.result.isSuccess else {
                print("Error while fetching data: \(String(describing: response.result.error))")
                completion(JSON.null, false)
                return
            }
            
            if let result = response.result.value {
                //print("******************** CHAT_MESSAGE_GET **********************")
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
     "id" : self.chatListModel.id,
     "message" : text,
     "type" : MessageContentType.Text.rawValue
    */
    func chatMessageSend(params: Parameters, completion: @escaping (JSON, Bool) -> Void) {
        Alamofire.request(API.CHAT_MESSAGE_SEND, method: .post, parameters: params, headers: getHeader()).responseJSON { (response) in
            guard response.result.isSuccess else {
                print("Error while fetching data: \(String(describing: response.result.error))")
                completion(JSON.null, false)
                return
            }
            
            if let result = response.result.value {
                print("******************** CHAT_MESSAGE_SEND **********************")
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
     "id" : String(self.chatListModel.id),
     "type" : String(MessageContentType.Image.rawValue)
     */
    func chatMessageSendFile(image: UIImage?, params: Parameters, completion: @escaping(JSON, Bool)->Void) {
        var imageData: Data!
        if image != nil {
            imageData = image?.jpegData(compressionQuality: 0.3)
        }
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            if imageData != nil {
                multipartFormData.append(imageData!, withName: "file", fileName: "chat_image.jpg", mimeType: "image/jpeg")
            }
            for (key, value) in params {
                if value is String {
                    multipartFormData.append((value as AnyObject).data(using: String.Encoding.utf8.rawValue)!, withName: key)
                }
            }
        }, to: API.CHAT_MESSAGE_SEND,
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
                        print("******************** CHAT_MESSAGE_SEND ********************** File ***")
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
        
    }
    
    func userList(page: Int, params: Parameters, completion: @escaping (JSON, Bool) -> Void) {
        let url = String(format: API.USER_LIST, "\(page)")
        Alamofire.request(url, method: .post, parameters: params, headers: getHeader()).responseJSON { (response) in
            guard response.result.isSuccess else {
                print("Error while fetching data: \(String(describing: response.result.error))")
                completion(JSON.null, false)
                return
            }
            
            if let result = response.result.value {
                //print("******************** USER_LIST **********************")
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
     "ids" : []
     */
    func chatCreate(params: Parameters, completion: @escaping (JSON, Bool) -> Void) {
        Alamofire.request(API.CHAT_CREATE, method: .post, parameters: params, headers: getHeader()).responseJSON { (response) in
            guard response.result.isSuccess else {
                print("Error while fetching data: \(String(describing: response.result.error))")
                completion(JSON.null, false)
                return
            }
            
            if let result = response.result.value {
                print("******************** CHAT_CREATE **********************")
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
     "id" : 94
     */
    func chatDetail(params: Parameters, completion: @escaping (JSON, Bool) -> Void) {
        Alamofire.request(API.CHAT_DETAIL, method: .post, parameters: params, headers: getHeader()).responseJSON { (response) in
            guard response.result.isSuccess else {
                print("Error while fetching data: \(String(describing: response.result.error))")
                completion(JSON.null, false)
                return
            }
            
            if let result = response.result.value {
                //print("******************** CHAT_DETAIL **********************")
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
     "id" : 94
     */
    func chatLeave(params: Parameters, completion: @escaping (JSON, Bool) -> Void) {
        Alamofire.request(API.CHAT_LEAVE, method: .post, parameters: params, headers: getHeader()).responseJSON { (response) in
            guard response.result.isSuccess else {
                print("Error while fetching data: \(String(describing: response.result.error))")
                completion(JSON.null, false)
                return
            }
            
            if let result = response.result.value {
                //print("******************** CHAT_LEAVE **********************")
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
    
    func chatBadge(badge: Int = 0, completion: @escaping (JSON, Bool) -> Void) {
        let params : Parameters = [
            "badge" : badge,
//            "token" : UserInstance.deviceToken!
        ]
        Alamofire.request(API.CHAT_BADGE, method: .post, parameters: params, headers: getHeader()).responseJSON { (response) in
            guard response.result.isSuccess else {
                print("Error while fetching data: \(String(describing: response.result.error))")
                completion(JSON.null, false)
                return
            }
            
            if let result = response.result.value {
                print("******************** CHAT_BADGE **********************")
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
    
    func userInfo(params: Parameters, completion: @escaping (JSON, Bool) -> Void) {
        Alamofire.request(API.USER_INFO, method: .post, parameters: params, headers: getHeader()).responseJSON { (response) in
            guard response.result.isSuccess else {
                print("Error while fetching data: \(String(describing: response.result.error))")
                completion(JSON.null, false)
                return
            }
            
            if let result = response.result.value {
                //print("******************** USER_INFO **********************")
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
    
    func liveList(page: Int, completion: @escaping (JSON, Bool) -> Void) {
        let url = String(format: API.LIVE_LIST, "\(page)")
        Alamofire.request(url, method: .post, headers: getHeader()).responseJSON { (response) in
            guard response.result.isSuccess else {
                print("Error while fetching data: \(String(describing: response.result.error))")
                completion(JSON.null, false)
                return
            }
            
            if let result = response.result.value {
                print("******************** LIVE_LIST **********************")
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
    
    func pushUrl(params: Parameters, completion: @escaping (JSON, Bool) -> Void) {
        Alamofire.request(API.LIVE_PUSH_URL, method: .post, parameters: params, headers: getHeader()).responseJSON { (response) in
            guard response.result.isSuccess else {
                print("Error while fetching data: \(String(describing: response.result.error))")
                completion(JSON.null, false)
                return
            }
            
            if let result = response.result.value {
                //print("******************** LIVE_PUSH_URL **********************")
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
    
    func pushStart(params: Parameters, completion: @escaping (JSON, Bool) -> Void) {
        Alamofire.request(API.LIVE_PUSH_START, method: .post, parameters: params, headers: getHeader()).responseJSON { (response) in
            guard response.result.isSuccess else {
                print("Error while fetching data: \(String(describing: response.result.error))")
                completion(JSON.null, false)
                return
            }
            
            if let result = response.result.value {
                print("******************** LIVE_PUSH_START **********************")
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
    
    func pushStop(params: Parameters, completion: @escaping (JSON, Bool) -> Void) {
        Alamofire.request(API.LIVE_PUSH_STOP, method: .post, parameters: params, headers: getHeader()).responseJSON { (response) in
            guard response.result.isSuccess else {
                print("Error while fetching data: \(String(describing: response.result.error))")
                completion(JSON.null, false)
                return
            }
            
            if let result = response.result.value {
                print("******************** LIVE_PUSH_STOP **********************")
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
    
    func playUrl(params: Parameters, completion: @escaping (JSON, Bool) -> Void) {
        Alamofire.request(API.LIVE_PLAY_URL, method: .post, parameters: params, headers: getHeader()).responseJSON { (response) in
            guard response.result.isSuccess else {
                print("Error while fetching data: \(String(describing: response.result.error))")
                completion(JSON.null, false)
                return
            }
            
            if let result = response.result.value {
                print("******************** LIVE_PLAY_URL **********************")
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
    
    func livePushExtend(params: Parameters, completion: @escaping (JSON, Bool) -> Void) {
        Alamofire.request(API.LIVE_PUSH_EXTEND, method: .post, parameters: params, headers: getHeader()).responseJSON { (response) in
            guard response.result.isSuccess else {
                print("Error while fetching data: \(String(describing: response.result.error))")
                completion(JSON.null, false)
                return
            }
            
            if let result = response.result.value {
                print("******************** LIVE_PUSH_EXTEND **********************")
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
    
    func livePlayExtend(params: Parameters, completion: @escaping (JSON, Bool) -> Void) {
        Alamofire.request(API.LIVE_PLAY_EXTEND, method: .post, parameters: params, headers: getHeader()).responseJSON { (response) in
            guard response.result.isSuccess else {
                print("Error while fetching data: \(String(describing: response.result.error))")
                completion(JSON.null, false)
                return
            }
            
            if let result = response.result.value {
                print("******************** LIVE_PLAY_EXTEND **********************")
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
    
    func liveChatGet(params: Parameters, completion: @escaping (JSON, Bool) -> Void) {
        Alamofire.request(API.LIVE_CHAT_GET, method: .post, parameters: params, headers: getHeader()).responseJSON { (response) in
            guard response.result.isSuccess else {
                print("Error while fetching data: \(String(describing: response.result.error))")
                completion(JSON.null, false)
                return
            }
            
            if let result = response.result.value {
                print("******************** LIVE_CHAT_GET **********************")
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
    
    func liveChatSend(params: Parameters, completion: @escaping (JSON, Bool) -> Void) {
        Alamofire.request(API.LIVE_CHAT_SEND, method: .post, parameters: params, headers: getHeader()).responseJSON { (response) in
            guard response.result.isSuccess else {
                print("Error while fetching data: \(String(describing: response.result.error))")
                completion(JSON.null, false)
                return
            }
            
            if let result = response.result.value {
                print("******************** LIVE_CHAT_SEND **********************")
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
    
    func liveLike(params: Parameters, completion: @escaping (JSON, Bool) -> Void) {
        Alamofire.request(API.LIVE_LIKE, method: .post, parameters: params, headers: getHeader()).responseJSON { (response) in
            guard response.result.isSuccess else {
                print("Error while fetching data: \(String(describing: response.result.error))")
                completion(JSON.null, false)
                return
            }
            
            if let result = response.result.value {
                print("******************** LIVE_LIKE **********************")
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
    
    func liveFavoriteList(page: Int, completion: @escaping (JSON, Bool) -> Void) {
        let url = String(format: API.LIVE_FAVORITE_LIST, "\(page)")
        Alamofire.request(url, method: .post, headers: getHeader()).responseJSON { (response) in
            guard response.result.isSuccess else {
                print("Error while fetching data: \(String(describing: response.result.error))")
                completion(JSON.null, false)
                return
            }
            
            if let result = response.result.value {
                //print("******************** LIVE_FAVORITE_LIST **********************")
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
    
    func liveFavoriteAdd(params: Parameters, completion: @escaping (JSON, Bool) -> Void) {
        Alamofire.request(API.LIVE_FAVORITE_ADD, method: .post, parameters: params, headers: getHeader()).responseJSON { (response) in
            guard response.result.isSuccess else {
                print("Error while fetching data: \(String(describing: response.result.error))")
                completion(JSON.null, false)
                return
            }
            
            if let result = response.result.value {
                //print("******************** LIVE_FAVORITE_ADD **********************")
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
    
    
    func liveFavoriteDelete(params: Parameters, completion: @escaping (JSON, Bool) -> Void) {
        Alamofire.request(API.LIVE_FAVORITE_DELETE, method: .post, parameters: params, headers: getHeader()).responseJSON { (response) in
            guard response.result.isSuccess else {
                print("Error while fetching data: \(String(describing: response.result.error))")
                completion(JSON.null, false)
                return
            }
            
            if let result = response.result.value {
                //print("******************** LIVE_FAVORITE_DELETE **********************")
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












