//
//  TaskData.swift
//  Todo
//
//  Created by TomL on 31/8/2565 BE.
//

import Foundation

struct TasksList: Decodable {
    let list: [Task]
}

struct Task: Decodable {
    let id: String
    let name: String
    let createdAt: String
    let imageUrl: String
}
