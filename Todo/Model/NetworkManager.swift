//
//  NetworkManager.swift
//  Todo
//
//  Created by TomL on 31/8/2565 BE.
//

import UIKit
import SwiftKeychainWrapper

protocol NetworkManagerDelegate {
    func didUpdateModel(model: TaskModel)
    func didFailedWithError(error: Error)
    func didUpdateUserModel(model: UserModel)
}

struct NetworkManager {
    
    var delegate: NetworkManagerDelegate?
    
    func getCurrentUser(URL: URL) {
        let accessToken: String? = KeychainWrapper.standard.string(forKey: "accessToken")
        let userId: String? = KeychainWrapper.standard.string(forKey: "userId")
        
        var request = URLRequest(url: URL)
        request.httpMethod = "GET"
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        let urlString = APIPath.mainPath + APIPath.getUser
        self.performFetchUserRequest(urlString: urlString)
    }
    
    func addNewTaskRequest(URL: URL, text: String) {
        let accessToken: String? = KeychainWrapper.standard.string(forKey: "accessToken")

        var request = URLRequest(url: URL)
        request.httpMethod = "POST"
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let postString = ["description": text] as [String: Any]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: postString, options: .prettyPrinted)
        } catch let error {
            print(error.localizedDescription)
            return
        }
        
        let urlString = APIPath.mainPath + APIPath.addTask
        self.performRequest(urlString: urlString)
    }
    
    func updateTask(URL: URL, id: String, text: String) {
        let accessToken: String? = KeychainWrapper.standard.string(forKey: "accessToken")

        var request = URLRequest(url: URL)
        request.httpMethod = "PUT"
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let putString = ["description": text] as [String: Any]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: putString, options: .prettyPrinted)
        } catch let error {
            print(error.localizedDescription)
            return
        }
        
        let urlString = APIPath.mainPath + APIPath.updateTask
        self.performRequest(urlString: urlString)
    }
    
    func deleteTask(URL: URL, id: String) {
        let accessToken: String? = KeychainWrapper.standard.string(forKey: "accessToken")

        var request = URLRequest(url: URL)
        request.httpMethod = "DELETE"
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let urlString = APIPath.mainPath + APIPath.deleteTask
        self.performRequest(urlString: urlString)
    }
    
    func getTaskList(URL: URL) {
        let accessToken: String? = KeychainWrapper.standard.string(forKey: "accessToken")
        var request = URLRequest(url: URL)
        request.httpMethod = "GET"
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let urlString = APIPath.mainPath + APIPath.allTasks
        self.performRequest(urlString: urlString)
    }
    
    func performRequest(urlString: String) {
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { data, response, error in
                if error != nil {
                    delegate?.didFailedWithError(error: error!)
                    return
                }
                
                if let safeData = data {
                    if let todoTask = self.parseJSON(data: safeData) {
                        delegate?.didUpdateModel(model: todoTask)
                    }
                }
            }
            task.resume()
        }
    }
    
    func performFetchUserRequest(urlString: String) {
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { data, response, error in
                if error != nil {
                    delegate?.didFailedWithError(error: error!)
                    return
                }
                
                if let safeData = data {
                    if let currentUser = self.parseJSONUser(data: safeData) {
                        delegate?.didUpdateUserModel(model: currentUser)
                    }
                }
            }
            task.resume()
        }
    }
    
    func parseJSON(data: Data) -> TaskModel? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(TasksList.self, from: data)
            
            let id = decodedData.list[0].id
            let name = decodedData.list[0].name
            let createdAt = decodedData.list[0].createdAt
            let imageUrl = decodedData.list[0].imageUrl
            
            let taskObj = TaskModel(id: id, name: name, createdAt: createdAt, imageUrl: imageUrl)
            return taskObj
        } catch {
            delegate?.didFailedWithError(error: error)
            return nil
        }
    }
    
    func parseJSONUser(data: Data) -> UserModel? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(CurrentUser.self, from: data)
            
            let name = decodedData.name
            let age = decodedData.age
            let email = decodedData.email
            
            let userObj = UserModel(name: name, age: age, email: email)
            return userObj
        } catch {
            delegate?.didFailedWithError(error: error)
            return nil
        }
    }
}
