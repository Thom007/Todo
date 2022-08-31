//
//  TodoViewController.swift
//  Todo
//
//  Created by TomL on 31/8/2565 BE.
//

import UIKit
import SwiftKeychainWrapper

class TodoViewController: UIViewController {
    
    @IBOutlet weak var todoListTableView: UITableView!
    @IBOutlet weak var customTabbarView: UIView!
    
    let networkManager = NetworkManager()
    var taskModel = [TaskModel]()
    
    private let calendarButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
        button.layer.masksToBounds = true
        button.layer.cornerRadius = button.frame.size.height / 2
        button.setBackgroundImage(UIImage(systemName: "calendar.circle"), for: .normal)
        button.tintColor = .darkGray
        button.addTarget(self, action: #selector(calendarButtonPressed(_:)), for: .touchUpInside)
        return button
    }()
    
    private let addButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
        button.backgroundColor = .orange
        let image = UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(pointSize: 26, weight: .medium))
        button.setImage(image, for: .normal)
        button.tintColor = .white
        button.layer.cornerRadius = button.frame.size.height / 2
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(addButtonPressed(_:)), for: .touchUpInside)
        return button
    }()
    
    private let checkmarkButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
        button.backgroundColor = .purple
        let image = UIImage(systemName: "checkmark", withConfiguration: UIImage.SymbolConfiguration(pointSize: 26, weight: .medium))
        button.setImage(image, for: .normal)
        button.tintColor = .white
        button.layer.cornerRadius = button.frame.size.height / 2
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(checkmarkButtonPressed(_:)), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupUI()
        getCurrentUser()
        getAllTasks()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupTableView()
        setupUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupFloatingButtons()
    }
    
    @objc private func signOut() {
        KeychainWrapper.standard.removeObject(forKey: "accessToken")
        KeychainWrapper.standard.removeObject(forKey: "userId")
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let signInVC = sb.instantiateViewController(withIdentifier: VC.signInVC) as! SignInViewController
        let appDelegate = UIApplication.shared.delegate
        appDelegate?.window??.rootViewController = signInVC
    }
    
    @objc func calendarButtonPressed(_ sender: Any) {
        
    }
    
    @objc func addButtonPressed(_ sender: Any) {
        let alert = UIAlertController(title: "New Item", message: "Enter task detail", preferredStyle: .alert)
        
        alert.addTextField { field in
            field.placeholder = "Enter task here ..."
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Submit", style: .default, handler: { [weak self] (_) in
            guard let field = alert.textFields?.first, let text = field.text, !text.isEmpty else {
                return
            }
            self?.createTask(text: text)
        }))
        present(alert, animated: true)
    }
    
    @objc func checkmarkButtonPressed(_ sender: Any) {
        
    }
    
    func getCurrentUser() {
        let url = URL(string: APIPath.mainPath + APIPath.getUser)!
        networkManager.getCurrentUser(URL: url)
    }
    
    func createTask(text: String) {
        let url = URL(string: APIPath.mainPath + APIPath.addTask)!
        networkManager.addNewTaskRequest(URL: url, text: text)
        todoListTableView.reloadData()
    }
    
    func updateTask(model: TaskModel, id: String, newName: String) {
        let url = URL(string: APIPath.mainPath + APIPath.updateTask)!
        networkManager.updateTask(URL: url, id: id, text: newName)
        todoListTableView.reloadData()
    }
    
    func deleteTask(id: String) {
        let url = URL(string: APIPath.mainPath + APIPath.deleteTask)!
        networkManager.deleteTask(URL: url, id: id)
        todoListTableView.reloadData()
    }
    
    func getAllTasks() {
        let url = URL(string: APIPath.mainPath + APIPath.allTasks)!
        networkManager.getTaskList(URL: url)
        todoListTableView.reloadData()
    }

}

extension TodoViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskModel.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "", for: indexPath) as! TaskCell
        let model = taskModel[indexPath.row]
        cell.nameLabel.text = model.name
        
        let date = taskModel[indexPath.row].createdAt
        let dateObj = cell.convertStringToDate(dateString: date)
        let dayString = cell.getDayForDate(dateObj)
        cell.dateLabel.text = dayString
        
        let timeString = cell.getTimeForDate(dateObj)
        cell.timeLabel.text = timeString
        return cell
    }
}

extension TodoViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(90)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let taskId = taskModel[indexPath.row].id
        let task = taskModel[indexPath.row]
        
        let sheet = UIAlertController(title: "Edit", message: nil, preferredStyle: .actionSheet)
    
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        sheet.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] _ in
            self?.deleteTask(id: taskId)
        }))
        sheet.addAction(UIAlertAction(title: "Edit", style: .default, handler: { [weak self] _ in
            
            let alert = UIAlertController(title: "Edit Item", message: "Edit task detail", preferredStyle: .alert)
            
            alert.addTextField(configurationHandler: nil)
            alert.textFields?.first?.text = task.name
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { [weak self] (_) in
                guard let field = alert.textFields?.first, let newName = field.text, !newName.isEmpty else {
                    return
                }
                self?.updateTask(model: task, id: taskId, newName: newName)
            }))
            self?.present(alert, animated: true)
        }))
        present(sheet, animated: true)
    }
}

extension TodoViewController {
    func setupTableView() {
        todoListTableView.delegate = self
        todoListTableView.dataSource = self
        todoListTableView.backgroundColor = .lightText
        todoListTableView.register(UINib(nibName: Nibname.taskCellNib, bundle: nil), forCellReuseIdentifier: CellIdentifier.taskCell)
        todoListTableView.separatorStyle = .none
        todoListTableView.backgroundView = UIImageView(image: UIImage(named: "abstractbg"))
    }
    
    func setupUI() {
        title = "Core Data Todo List"
        navigationController?.navigationBar.prefersLargeTitles = false
        customTabbarView.alpha = 0.2
        customTabbarView.layer.borderColor = UIColor.clear.cgColor
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "rectangle.portrait.and.arrow.right"), style: .plain, target: self, action: #selector(signOut))
        view.addSubview(calendarButton)
        view.addSubview(addButton)
        view.addSubview(checkmarkButton)
    }
    
    func setupFloatingButtons() {
        calendarButton.frame = CGRect(
            x: view.center.x - 25,
            y: 770,
            width: 60,
            height: 60)
        checkmarkButton.frame = CGRect(x: view.center.x - 145, y: 780, width: 60, height: 60)
        addButton.frame = CGRect(x: view.center.x + 95, y: 780, width: 60, height: 60)
    }
}
