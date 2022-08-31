//
//  TaskCell.swift
//  Todo
//
//  Created by TomL on 31/8/2565 BE.
//

import UIKit

class TaskCell: UITableViewCell {
    
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!

    var networkManager = NetworkManager()
    var taskModel = [TaskModel]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUIElements()
        networkManager.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = self.contentView.frame.insetBy(dx: 20, dy: 10)
        contentView.layer.cornerRadius = 10
        contentView.layer.borderColor = UIColor.lightGray.cgColor
        contentView.layer.borderWidth = 0.65
        contentView.backgroundColor = .white
    }
    
    func setupUIElements() {
        self.backgroundColor = .clear
        dateLabel.font = UIFont.systemFont(ofSize: 15, weight: .heavy)
        timeLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        
        icon.layer.cornerRadius = icon.frame.size.height / 2
        icon.clipsToBounds = true
        icon.image = UIImage(systemName: "paperplane.fill")
        icon.backgroundColor = .darkGray
    }
    
    func convertStringToDate(dateString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let dateObj = formatter.date(from: dateString)
        return dateObj
    }
  
    func getDayForDate(_ date: Date?) -> String {
        guard let inputDate = date else {
            return ""
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM"
        return formatter.string(from: inputDate)
    }
    
    func getTimeForDate(_ date: Date?) -> String {
        guard let inputDate = date else {
            return ""
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: inputDate)
    }
}

extension TaskCell: NetworkManagerDelegate {
    func didUpdateUserModel(model: UserModel) {
        
    }
    
    func didUpdateModel(model: TaskModel) {
        nameLabel.text = model.name
        dateLabel.text = model.createdAt
        timeLabel.text = model.createdAt
        taskModel.append(model)
    }
    
    func didFailedWithError(error: Error) {
        print(error)
    }
}
