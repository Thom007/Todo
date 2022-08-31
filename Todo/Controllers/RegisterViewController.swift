//
//  RegisterViewController.swift
//  Todo
//
//  Created by TomL on 31/8/2565 BE.
//

import UIKit

class RegisterViewController: UIViewController {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var ageTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        print("Cancel Registration")
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func registerButtonPressed(_ sender: Any) {
        print("Register a new account!")
        
        if (nameTextField.text?.isEmpty)! ||
            (ageTextField.text?.isEmpty)! ||
            (emailTextField.text?.isEmpty)! ||
            (passwordTextField.text?.isEmpty)! ||
            (confirmPasswordTextField.text?.isEmpty)! {
            
            displayAlertMessage(userMessage: "All fields are required to fill in")
            return
        }
        
        if ((passwordTextField.text?.elementsEqual(confirmPasswordTextField.text!))! != true) {
            displayAlertMessage(userMessage: "Password must match")
            return
        }
    
        let url = URL(string: APIPath.mainPath + APIPath.register)
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let postString = ["name": nameTextField.text,
                          "email": emailTextField.text,
                          "password": passwordTextField.text,
                          "age": Int(ageTextField.text!)] as [String : Any]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: postString, options: .prettyPrinted)
        } catch let error {
            print(error.localizedDescription)
            displayAlertMessage(userMessage: "Something went wrong. Retry.")
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?)  in
            if error != nil {
                self.displayAlertMessage(userMessage: "Could not perform request")
                print("error: \(String(describing: error))")
                return
            }
        
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary
                if let parJson = json {
                    let userId = parJson["userId"] as? String
                    print("User ID: \(String(describing: userId!))")
                    
                    if (userId?.isEmpty)! {
                        self.displayAlertMessage(userMessage: "Could not perform request successfully")
                        return
                    } else {
                        self.displayAlertMessage(userMessage: "Successfully registered. Please proceed to sign in.")
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
