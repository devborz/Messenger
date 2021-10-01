//
//  PhotoMessageCell.swift
//  Messenger
//
//  Created by Усман Туркаев on 24.08.2021.
//

import UIKit

final class PhotoMessageCell: MessageCell {
    
    let photoImageView = UIImageView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .clear
        
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        photoImageView.translatesAutoresizingMaskIntoConstraints = false
        bubbleView.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        stateImageView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(bubbleView)
        contentView.addSubview(avatarImageView)
        bubbleView.addSubview(photoImageView)
        bubbleView.addSubview(timeLabel)
        
        photoImageView.topAnchor.constraint(equalTo: bubbleView.topAnchor).isActive = true
        photoImageView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor).isActive = true
        photoImageView.rightAnchor.constraint(equalTo: bubbleView.rightAnchor).isActive = true
        photoImageView.bottomAnchor.constraint(equalTo: timeLabel.topAnchor, constant: -3).isActive = true
        photoImageView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        photoImageView.widthAnchor.constraint(equalToConstant: 140).isActive = true
        photoImageView.contentMode = .scaleAspectFill
        photoImageView.backgroundColor = .secondarySystemBackground
        
        timeLabel.leftAnchor.constraint(equalTo: bubbleView.leftAnchor, constant: 10).isActive = true
        timeLabel.rightAnchor.constraint(equalTo: bubbleView.rightAnchor, constant: -10).isActive = true
        timeLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -5).isActive = true
        timeLabel.heightAnchor.constraint(equalToConstant: 10).isActive = true
        
        timeLabel.font = .systemFont(ofSize: 10)
        timeLabel.textAlignment = .right
        
        avatarImageView.backgroundColor = .secondarySystemBackground
        avatarImageView.layer.cornerRadius = 15
        avatarImageView.clipsToBounds = true
        avatarImageView.tintColor = avatarTintColor
        
        stateImageView.heightAnchor.constraint(equalToConstant: 15).isActive = true
        stateImageView.widthAnchor.constraint(equalToConstant: 15).isActive = true
        stateImageView.backgroundColor = .clear
        stateImageView.contentMode = .scaleAspectFit
        
        bubbleView.backgroundColor = .clear
        timeLabel.textColor = .secondaryLabel
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(messageTapped))
        photoImageView.addGestureRecognizer(gestureRecognizer)
        photoImageView.isUserInteractionEnabled = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        viewModel?.senderAvatar.removeListener()
        viewModel?.state.removeListener()
        viewModel?.messagePhoto.removeListener()
        viewModel = nil
    }
    
    @objc
    func messageTapped() {
        switch viewModel.model.attachment {
        case .image(url: let url):
            if url.isEmpty {
                if let image = viewModel.messagePhoto.value {
                    delegate?.photoTapped(cell: self, image: image)
                }
            } else {
                delegate?.photoWithURLTapped(cell: self, url: url)
            }
        default:
            break
        }
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
        case .outgoing:
            contentView.addSubview(stateImageView)
            
            avatarImageView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -10).isActive = true
            bubbleView.rightAnchor.constraint(equalTo: avatarImageView.leftAnchor, constant: -10).isActive = true
            
            stateImageView.rightAnchor.constraint(equalTo: bubbleView.leftAnchor, constant: -15).isActive = true
            stateImageView.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor).isActive = true
        }
    }
    
    func setup(_ viewModel: MessageViewModel) {
        self.viewModel = viewModel
        photoImageView.layer.cornerRadius = 20
        photoImageView.clipsToBounds = true
        timeLabel.text = formatMessageTime(viewModel.model.created)
        layout()
        viewModel.senderAvatar.bind { [weak self] image in
            DispatchQueue.main.async {
                self?.avatarImageView.image = image
            }
        }
        viewModel.messagePhoto.bind { [weak self] image in
            DispatchQueue.main.async {
                self?.photoImageView.image = image
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
