//
//  TextMessageCell.swift
//  Pangea
//
//  Created by Усман Туркаев on 16.08.2021.
//

import UIKit

final class TextMessageCell: MessageCell {
    
    let contentLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .clear
        
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        contentLabel.translatesAutoresizingMaskIntoConstraints = false
        bubbleView.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        stateImageView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(bubbleView)
        contentView.addSubview(avatarImageView)
        bubbleView.addSubview(contentLabel)
        bubbleView.addSubview(timeLabel)
        
        contentLabel.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 10).isActive = true
        contentLabel.leftAnchor.constraint(equalTo: bubbleView.leftAnchor, constant: 10).isActive = true
        contentLabel.rightAnchor.constraint(equalTo: bubbleView.rightAnchor, constant: -10).isActive = true
        contentLabel.bottomAnchor.constraint(equalTo: timeLabel.topAnchor, constant: -2).isActive = true
        
        timeLabel.leftAnchor.constraint(equalTo: bubbleView.leftAnchor, constant: 10).isActive = true
        timeLabel.rightAnchor.constraint(equalTo: bubbleView.rightAnchor, constant: -10).isActive = true
        timeLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -5).isActive = true
        timeLabel.heightAnchor.constraint(equalToConstant: 10).isActive = true
        
        timeLabel.font = .systemFont(ofSize: 10)
        timeLabel.textAlignment = .right
        
        contentLabel.numberOfLines = 0
        
        avatarImageView.backgroundColor = .secondarySystemBackground
        avatarImageView.tintColor = avatarTintColor
        avatarImageView.layer.cornerRadius = 15
        avatarImageView.clipsToBounds = true
        
        stateImageView.heightAnchor.constraint(equalToConstant: 15).isActive = true
        stateImageView.widthAnchor.constraint(equalToConstant: 15).isActive = true
        stateImageView.backgroundColor = .clear
        stateImageView.contentMode = .scaleAspectFit
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        viewModel?.senderAvatar.removeListener()
        viewModel?.state.removeListener()
        viewModel = nil
    }
    
    func layout() {
        avatarImageView.removeFromSuperview()
        bubbleView.removeFromSuperview()
        stateImageView.removeFromSuperview()
        
        contentView.addSubview(bubbleView)
        contentView.addSubview(avatarImageView)
        
        avatarImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10).isActive = true
        avatarImageView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        avatarImageView.widthAnchor.constraint(equalToConstant: 30).isActive = true
        
        bubbleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10).isActive = true
        bubbleView.widthAnchor.constraint(lessThanOrEqualToConstant: frame.width * 0.7).isActive = true
        bubbleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10).isActive = true
        
        switch viewModel.type {
        case .incoming:
            avatarImageView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 10).isActive = true
            bubbleView.leftAnchor.constraint(equalTo: avatarImageView.rightAnchor, constant: 10).isActive = true
            
            bubbleView.backgroundColor = incomingMessageColor
            timeLabel.textColor = .lightGray
            contentLabel.textColor = .label
        case .outgoing:
            contentView.addSubview(stateImageView)
            
            avatarImageView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -10).isActive = true
            bubbleView.rightAnchor.constraint(equalTo: avatarImageView.leftAnchor, constant: -10).isActive = true
        
            bubbleView.clipsToBounds = true
            
            bubbleView.backgroundColor = .systemIndigo
            timeLabel.textColor = .lightText
            
            contentLabel.textColor = .white
            
            stateImageView.rightAnchor.constraint(equalTo: bubbleView.leftAnchor, constant: -15).isActive = true
            stateImageView.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor).isActive = true
        }
    }
    
    func setup(_ viewModel: MessageViewModel) {
        self.viewModel = viewModel
        contentLabel.text = viewModel.model.text
        timeLabel.text = formatMessageTime(viewModel.model.created)
        bubbleView.layer.cornerRadius = 15
        bubbleView.clipsToBounds = true
        layout()
        viewModel.senderAvatar.bind { [weak self] image in
            DispatchQueue.main.async {
                self?.avatarImageView.image = image
            }
        }
        viewModel.state.bind { [weak self] state in
            var image: UIImage?
            var tintColor: UIColor = .systemIndigo
            switch state {
            case .normal:
                image = nil
            case .sending:
                image = UIImage(systemName: "clock")
            case .sent:
                image = nil
            case .errorOccured:
                image = UIImage(systemName: "exclamationmark.shield.fill")
                tintColor = .red
            }
            DispatchQueue.main.async {
                self?.stateImageView.image = image
                self?.stateImageView.tintColor = tintColor
            }
        }
    }
}
