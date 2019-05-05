

import Foundation
import SwiftyJSON


public struct CityModel {
    var id: Int?
    var name: String?
    var parent: Int?
    
    init(_ json: JSON) {
        self.id = json["id"].intValue
        self.name = json["name"].stringValue
        self.parent = json["parent"].intValue
    }
    
    static func getCitiesFromJson(_ jsons: JSON) -> [CityModel] {
        var cities: [CityModel] = []
        for json in jsons.arrayValue {
            let city = CityModel(json)
            cities.append(city)
        }
        return cities
    }
    
}






