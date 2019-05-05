//
//  ExampleData.swift
//  ios-swift-collapsible-table-section
//
//  Created by Yong Su on 8/1/17.
//  Copyright © 2017 Yong Su. All rights reserved.
//

import Foundation

//
// MARK: - Section Data Structure
//

public struct Section {
    var firstInvite: NSDictionary
    var items: [NSDictionary]
    var collapsed: Bool
    
    public init(firstInvite: NSDictionary, items: [NSDictionary], collapsed: Bool = true) {
        self.firstInvite = firstInvite
        self.items = items
        self.collapsed = collapsed
    }
}

