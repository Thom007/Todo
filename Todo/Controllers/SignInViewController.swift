//
//  SignInViewController.swift
//  Todo
//
//  Created by TomL on 31/8/2565 BE.
//

import UIKit
import SwiftKeychainWrapper

class SignInViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    let networkManager = NetworkManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    @IBAction func signInButtonPressed(_ sender: Any) {
        
        let username = emailTextField.text
        let password = passwordTextField.text
        
        if (username?.isEmpty)! || (password?.isEmpty)! {
            print("Both fields must not be empty!")
            displayAlertMessage(userMessage: "Both fields must not be empty!")
            return
        }
        
        let url = URL(string: APIPath.mainPath + APIPath.login)
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let postString = ["email": username, "password": password] as [String: String]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: postString, options: .prettyPrinted)
        } catch let error {
            print(error.localizedDescription)
            displayAlertMessage(userMessage: "Something went wrong")
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            
            if error != nil {
                self.displayAlertMessage(userMessage: "Could not perform request")
                print("error: \(String(describing: error))")
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary
                
                if let parseJson = json {
                    let accessToken = parseJson["token"] as? String
                    let userId = parseJson["id"] as? String
                    print("Access Token: \(String(describing: accessToken))")
                    
                    if (accessToken?.isEmpty)! {
                        self.displayAlertMessage(userMessage: "Could not successfully perform request")
                        return
                    }
                    
                    let saveAccessToken: Bool = KeychainWrapper.standard.set(accessToken!, forKey: "accessToken")
                    let saveUserId: Bool = KeychainWrapper.standard.set(userId!, forKey: "userId")
                    
                    DispatchQueue.main.async {
                        let sb = UIStoryboard(name: "Main", bundle: nil)
                        let todoVC = sb.instantiateViewController(withIdentifier: VC.todoVC) as! TodoViewController
                        let appDelegate = UIApplication.shared.delegate
                        appDelegate?.window??.rootViewController = todoVC
                    }
                } else {
                    self.displayAlertMessage(userMessage: "Could not perform request successfully")
                }
            } catch {
                self.displayAlertMessage(userMessage: "Could not perform request successfully")
                print(error)
            }
        }
        task.resume()
    }
    
    @IBAction func signUpButtonPressed(_ sender: Any) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: VC.registerVC) as! RegisterViewController
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
    }
    
    func displayAlertMessage(userMessage: String) -> Void {
        let alert = UIAlertController(title: "Alert", message: userMessage, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            DispatchQueue.main.async {
                self.dismiss(animated: true, completion: nil)
            }
        }
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
}
