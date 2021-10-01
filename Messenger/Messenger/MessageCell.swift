//
//  MessageCell.swift
//  Pangea
//
//  Created by Усман Туркаев on 27.08.2021.
//

import UIKit

protocol MessageCellDelegate: AnyObject {
    func photoWithURLTapped(cell: PhotoMessageCell, url: String)
    
    func photoTapped(cell: PhotoMessageCell, image: UIImage)
    
    func locationTapped(cell: LocationMessageCell, location: Location)
}

class MessageCell: UITableViewCell {
    
    weak var delegate: MessageCellDelegate?

    var viewModel: MessageViewModel!
    
    let bubbleView = UIView()
    
    let timeLabel = UILabel()

    let avatarImageView = UIImageView()
    
    let stateImageView = UIImageView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
