//
//  Identifiers.swift
//  Todo
//
//  Created by TomL on 31/8/2565 BE.
//

import Foundation

struct VC {
    static let signInVC = "signInVC"
    static let registerVC = "registerVC"
    static let todoVC = "todoVC"
}

struct CellIdentifier {
    static let taskCell = "taskCell"
}

struct Nibname {
    static let taskCellNib = "TaskCell"
}

public struct APIPath {
    static let mainPath = "https://api-nodejs-todolist.herokuapp.com"
    static let register = "/user/register"
    static let login = "/user/login"
    static let logout = "/user/logout"
    static let allTasks = "/task"
    static let delete = "todos/$_id"
    static let getUser = "/user/me"
    static let addTask = "/task"
    static let updateTask = "/task/id"
    static let deleteTask = "/task/id"
}
