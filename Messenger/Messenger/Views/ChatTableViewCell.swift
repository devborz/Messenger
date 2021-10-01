//
//  ChatTableViewCell.swift
//  VKmessenger
//
//  Created by Усман Туркаев on 30.09.2020.
//

import UIKit

class ChatTableViewCell: UITableViewCell {
    
    @IBOutlet weak var chatNameLabel: UILabel!
    
    @IBOutlet weak var chatImageView: UIImageView!
    
    @IBOutlet weak var lastMessageLabel: UILabel!
    
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var verifiedImageView: UIImageView!
    
    @IBOutlet weak var chatStateImageView: UIImageView!
    
    var viewModel: ChatCellViewModel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        chatImageView.tintColor = avatarTintColor
        verifiedImageView.tintColor = .systemBlue
        backgroundColor = .systemBackground
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        viewModel?.otherUserImage.removeListener()
        viewModel?.unread.removeListener()
        viewModel?.lastMessage.removeListener()
        viewModel = nil
    }
    
    func setup(_ viewModel: ChatCellViewModel) {
        self.viewModel = viewModel
        viewModel.lastMessage.bind { [weak self] message in
            guard let message = message else { return }
            if message.senderID == DatabaseManager.shared.currentUserID {
                DispatchQueue.main.async {
                    self?.lastMessageLabel.text =  NSLocalizedString("You", comment: "") + ": " + message.placeholder
                    self?.timeLabel.text = self?.formatMessageDate(message.created)
                }
            } else {
                DispatchQueue.main.async {
                    self?.lastMessageLabel.text = message.placeholder
                    self?.timeLabel.text = self?.formatMessageDate(message.created)
                }
            }
        }
        self.chatNameLabel.text = viewModel.otherUserInfo.username
//        if viewModel.otherUserInfo.isVerified {
//            self.verifiedImageView.image = UIImage(systemName: "checkmark.seal.fill")
//        } else {
//            self.verifiedImageView.image = nil
//        }
        viewModel.otherUserImage.bind { [weak self] image in
            DispatchQueue.main.async {
                self?.chatImageView.image = image
            }
        }
        viewModel.unread.bind { [weak self] value in
            if value == 0 {
                DispatchQueue.main.async {
                    self?.chatStateImageView.image = nil
                }
            } else {
                DispatchQueue.main.async {
                    self?.chatStateImageView.image = UIImage(systemName: "\(value).circle.fill")
                }
            }
        }
    }
    
    private func formatMessageDate(_ messageDate: Date) -> String {
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd:MM:yyyy"
        if dateFormatter.string(from: currentDate) == dateFormatter.string(from: messageDate) {
            dateFormatter.dateFormat = "HH:mm"
            return dateFormatter.string(from: messageDate)
        } else {
            dateFormatter.dateFormat = "HH:mm dd MMM"
            return dateFormatter.string(from: messageDate)
        }
    }
}
