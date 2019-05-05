

import UIKit
import SwiftyJSON

public struct UserModel {
    
    var id: Int?
    var roleId: Int?
    var image: String?
    var address: String?
    var paiBalance: String?
    var gender: String?
    var name: String?
    var createdAt: String?
    //var store: StoreModel?
    var introduction: String?
    var phoneNumber: String?
    var degreeId: Int?
    var paiAddress: String?
    var rmbBalance: String?
    var point: Int?
    
    init(_ json: JSON) {
        self.id = json["id"].intValue
        self.roleId = json["role_id"].intValue
        self.image = json["image"].stringValue//API.IMAGE_URL + json["image"].stringValue
        self.address = json["address"].stringValue
        self.paiBalance = json["pai_balance"].stringValue
        self.gender =  json["gender"].stringValue
        self.name = json["name"].stringValue
        self.createdAt = json["created_at"].stringValue
        //self.store = StoreModel.init(json["store"])
        self.introduction = json["introduction"].stringValue
        self.phoneNumber = json["phone_number"].stringValue
        self.degreeId = json["degree_id"].intValue
        self.paiAddress = json["pai_address"].stringValue
        self.rmbBalance = json["yen_balance"].stringValue
        self.point = json["point"].intValue
    }
    
    
    static func getUsersFromJson(_ jsons: JSON) -> [UserModel] {
        var users: [UserModel] = []
        for json in jsons.arrayValue {
            let user = UserModel(json)
            users.append(user)
        }
        return users
    }
    
}









