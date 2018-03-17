//
//  Category.swift
//  Todoey
//
//  Created by Antony on 11/3/18.
//  Copyright © 2018 Antony. All rights reserved.
//

import Foundation
import RealmSwift

class Category : Object {
    @objc dynamic var name : String = ""
    @objc dynamic var bgColor : String = ""
    let items = List<Item>()
}
