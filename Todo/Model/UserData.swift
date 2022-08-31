//
//  UserData.swift
//  Todo
//
//  Created by TomL on 31/8/2565 BE.
//

import Foundation

struct CurrentUser: Decodable {
    let name: String
    let age: Int
    let email: String
}
