//
//  ContactModel.swift
//  paishop
//
//  Created by SeniorCorder on 6/13/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import Foundation
import SwiftyJSON


public struct ContactModel {
    var id: String!
    var name: String!
    var phoneNumber: String!
    var address: String!
    var main: Bool!
    
    init(_ json: JSON) {
        self.id = json["id"].stringValue
        self.name = json["name"].stringValue
        self.phoneNumber = json["phone_number"].stringValue
        self.address = json["address"].stringValue
        self.main = json["main"].boolValue
    }
    
    static func getContactsFromJson(_ jsons: JSON) -> [ContactModel] {
        var contacts: [ContactModel] = []
        for json in jsons.arrayValue {
            let contact = ContactModel(json)
            contacts.append(contact)
        }
        return contacts
    }
    
}


