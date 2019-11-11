//
//  Storage.swift
//  CityWeatherApp
//
//  Created by Apple on 11/5/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import Foundation

class Storage {
    static let shared: Storage = Storage()
    var cities = ["Warsaw", "London", "Los Angeles"]
    
    private init() { }
}
