
import Foundation
import SwiftyJSON

public struct DegreeModel {
    
    var id: Int? // 1 - bronze, 2 - silver, 3- gold, 4- supreme
    var name: String?
    var period: Int?
    var fee: Double?
    //var deletedAt: String?
    var image: String?
    var description: String?
    var profitRatio: Int?
    
    init(_ json: JSON) {
        self.id = json["id"].intValue
        self.name = json["name"].stringValue
        self.period = json["period"].intValue
        self.fee = json["fee"].doubleValue
        self.image = json["image"].stringValue//API.IMAGE_URL + json["image"].stringValue
        self.description = json["description"].stringValue
        self.profitRatio = json["profit_ratio"].intValue
    }
    
    static func getDegreesFromJson(_ jsons: JSON) -> [DegreeModel] {
        var degrees: [DegreeModel] = []
        for json in jsons.arrayValue {
            let degree = DegreeModel(json)
            degrees.append(degree)
        }
        return degrees
    }
    
}


