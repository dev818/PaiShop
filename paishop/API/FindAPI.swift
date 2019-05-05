
import Foundation
import Alamofire
import SwiftyJSON


class FindAPI {
    static let shared = FindAPI()
    
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
    
    func posts(page: Int, completion: @escaping (JSON, Bool) -> Void) {
        let url = String(format: API.POSTS, "\(page)")
        Alamofire.request(url, method: .post, headers: getHeader()).responseJSON { (response) in
            guard response.result.isSuccess else {
                print("Error while fetching data: \(String(describing: response.result.error))")
                completion(JSON.null, false)
                return
            }
            
            if let result = response.result.value {
                print("******************** POSTS **********************")
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
    
    // get posts
    func getPosts(completion: @escaping (NSDictionary, Bool) -> Void) {
        Alamofire.request(API.POSTSALL, method: .post, headers: getHeader()).responseJSON { response in
            if response.result.isSuccess {
                completion(response.result.value as! NSDictionary, true)
                return
                
            } else {
                completion(NSDictionary(), false)
                return
            }
            
        }
    }
    
    // get posts mine
    func getPostsMine(completion: @escaping (NSDictionary, Bool) -> Void) {
        Alamofire.request(API.POSTS_MINE, method: .post, headers: getHeader()).responseJSON { response in
            if response.result.isSuccess {
                completion(response.result.value as! NSDictionary, true)
                return
                
            } else {
                completion(NSDictionary(), false)
                return
            }
            
        }
    }
    
    // get favorites
    func getFavorites(completion: @escaping (NSDictionary, Bool) -> Void) {
        Alamofire.request(API.GET_FAVORITES, method: .post, headers: getHeader()).responseJSON { response in
            if response.result.isSuccess {
                completion(response.result.value as! NSDictionary, true)
                return
                
            } else {
                completion(NSDictionary(), false)
                return
            }
            
        }
    }
    
    
    // get comments
    func getComments(params: Parameters, completion: @escaping (NSDictionary, Bool) -> Void) {
        Alamofire.request(API.GET_COMMENTS, method: .post, parameters: params, headers: getHeader()).responseJSON { response in
            if response.result.isSuccess {
                completion(response.result.value as! NSDictionary, true)
                return
                
            } else {
                completion(NSDictionary(), false)
                return
            }
            
        }
    }
    
    // create comment
    func createComment(params: Parameters, completion: @escaping (NSDictionary, Bool) -> Void) {
        Alamofire.request(API.CREATE_COMMENT, method: .post, parameters: params, headers: getHeader()).responseJSON { response in
            if response.result.isSuccess {
                completion(response.result.value as! NSDictionary, true)
                return
                
            } else {
                completion(NSDictionary(), false)
                return
            }
            
        }
    }
    
    // add view
    func addView(params: Parameters, completion: @escaping (NSDictionary, Bool) -> Void) {
        Alamofire.request(API.ADD_VIEW, method: .post, parameters: params, headers: getHeader()).responseJSON { response in
            if response.result.isSuccess {
                completion(response.result.value as! NSDictionary, true)
                return
                
            } else {
                completion(NSDictionary(), false)
                return
            }
            
        }
    }
    
    // add favorite
    func addFavorite(params: Parameters, completion: @escaping (NSDictionary, Bool) -> Void) {
        Alamofire.request(API.ADD_FAVORITE, method: .post, parameters: params, headers: getHeader()).responseJSON { response in
            if response.result.isSuccess {
                completion(response.result.value as! NSDictionary, true)
                return
                
            } else {
                completion(NSDictionary(), false)
                return
            }
            
        }
    }
    
    // add report
    func addReport(params: Parameters, completion: @escaping (NSDictionary, Bool) -> Void) {
        Alamofire.request(API.ADD_REPORT, method: .post, parameters: params, headers: getHeader()).responseJSON { response in
            if response.result.isSuccess {
                completion(response.result.value as! NSDictionary, true)
                return
                
            } else {
                completion(NSDictionary(), false)
                return
            }
            
        }
    }
    
    // add like
    func addLike(params: Parameters, completion: @escaping (NSDictionary, Bool) -> Void) {
        Alamofire.request(API.ADD_LIKE, method: .post, parameters: params, headers: getHeader()).responseJSON { response in
            if response.result.isSuccess {
                completion(response.result.value as! NSDictionary, true)
                return
                
            } else {
                completion(NSDictionary(), false)
                return
            }
            
        }
    }
    
    // show author
    func showAuthor(params: Parameters, completion: @escaping (NSDictionary, Bool) -> Void) {
        Alamofire.request(API.SHOW_AUTHOR, method: .post, parameters: params, headers: getHeader()).responseJSON { response in
            if response.result.isSuccess {
                completion(response.result.value as! NSDictionary, true)
                return
                
            } else {
                completion(NSDictionary(), false)
                return
            }
            
        }
    }
    
    // remove favorite
    func removeFavorite(params: Parameters, completion: @escaping (NSDictionary, Bool) -> Void) {
        Alamofire.request(API.REMOVE_FAVORITE, method: .post, parameters: params, headers: getHeader()).responseJSON { response in
            if response.result.isSuccess {
                completion(response.result.value as! NSDictionary, true)
                return
                
            } else {
                completion(NSDictionary(), false)
                return
            }
            
        }
    }
    
    // remove report
    func removeReport(params: Parameters, completion: @escaping (NSDictionary, Bool) -> Void) {
        Alamofire.request(API.REMOVE_REPORT, method: .post, parameters: params, headers: getHeader()).responseJSON { response in
            if response.result.isSuccess {
                completion(response.result.value as! NSDictionary, true)
                return
                
            } else {
                completion(NSDictionary(), false)
                return
            }
            
        }
    }
    
    // remove like
    func removeLike(params: Parameters, completion: @escaping (NSDictionary, Bool) -> Void) {
        Alamofire.request(API.REMOVE_LIKE, method: .post, parameters: params, headers: getHeader()).responseJSON { response in
            if response.result.isSuccess {
                completion(response.result.value as! NSDictionary, true)
                return
                
            } else {
                completion(NSDictionary(), false)
                return
            }
            
        }
    }
    
    // hide author
    func hideAuthor(params: Parameters, completion: @escaping (NSDictionary, Bool) -> Void) {
        Alamofire.request(API.HIDE_AUTHOR, method: .post, parameters: params, headers: getHeader()).responseJSON { response in
            if response.result.isSuccess {
                completion(response.result.value as! NSDictionary, true)
                return
                
            } else {
                completion(NSDictionary(), false)
                return
            }
            
        }
    }
    
    // post active
    func postActive(params: Parameters, completion: @escaping (NSDictionary, Bool) -> Void) {
        Alamofire.request(API.POST_ACTIVE, method: .post, parameters: params, headers: getHeader()).responseJSON { response in
            if response.result.isSuccess {
                completion(response.result.value as! NSDictionary, true)
                return
                
            } else {
                completion(NSDictionary(), false)
                return
            }
            
        }
    }
    
    // post inactive
    func postInActive(params: Parameters, completion: @escaping (NSDictionary, Bool) -> Void) {
        Alamofire.request(API.POST_INACTIVE, method: .post, parameters: params, headers: getHeader()).responseJSON { response in
            if response.result.isSuccess {
                completion(response.result.value as! NSDictionary, true)
                return
                
            } else {
                completion(NSDictionary(), false)
                return
            }
            
        }
    }
    
    // post delete
    func postDelete(params: Parameters, completion: @escaping (NSDictionary, Bool) -> Void) {
        Alamofire.request(API.POST_DELETE, method: .post, parameters: params, headers: getHeader()).responseJSON { response in
            if response.result.isSuccess {
                completion(response.result.value as! NSDictionary, true)
                return
                
            } else {
                completion(NSDictionary(), false)
                return
            }
            
        }
    }
    


    
    func postCreate(params: Parameters, completion: @escaping (JSON, Bool) -> Void) {
        Alamofire.request(API.POST_CREATE, method: .post, parameters: params, headers: getHeader()).responseJSON { (response) in
            guard response.result.isSuccess else {
                print("Error while fetching data: \(String(describing: response.result.error))")
                completion(JSON.null, false)
                return
            }
            
            if let result = response.result.value {
                print("******************** POST_CREATE **********************")
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














