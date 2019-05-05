
import Foundation
import Alamofire

class NetworkUtil {
    
    class func isReachable() -> Bool {
        return NetworkReachabilityManager()!.isReachable
    }
    
    class func isReachableToHost() -> Bool {
        return NetworkReachabilityManager(host: API.HOST)!.isReachable
    }
    
    class func stopAllSessions() {
        Alamofire.SessionManager.default.session.getAllTasks { (tasks: [URLSessionTask]) in
            tasks.forEach { $0.cancel() }
        }
    }
    
    class func stopSession(_ lastPath: String) {
        Alamofire.SessionManager.default.session.getAllTasks { (tasks: [URLSessionTask]) in
            tasks.forEach {
                if $0.currentRequest?.url?.lastPathComponent == lastPath {
                    $0.cancel()
                }
            }
        }
    }
    
}
