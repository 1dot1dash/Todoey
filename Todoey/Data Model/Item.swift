//
//  Item.swift
//  Todoey
//
//  Created by Antony on 11/3/18.
//  Copyright © 2018 Antony. All rights reserved.
//

import Foundation
import RealmSwift

class Item : Object {
    @objc dynamic var title : String = ""
    @objc dynamic var done : Bool = false
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}
