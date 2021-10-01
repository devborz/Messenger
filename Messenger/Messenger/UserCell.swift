//
//  UserCell.swift
//  Pangea
//
//  Created by  AdamRouss🐺 on 18.03.2021.
//

import UIKit

class UserCell: UITableViewCell {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var verifiedImageView: UIImageView!
    
    var viewModel: UserCellViewModel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        avatarImageView.tintColor = avatarTintColor
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        avatarImageView.image = nil
        usernameLabel.text = nil
        viewModel?.avatar.removeListener()
        viewModel = nil
    }

    func setup(_ viewModel: UserCellViewModel) {
        self.viewModel = viewModel
        usernameLabel.text = viewModel.username
        verifiedImageView.image = viewModel.isVerified ? UIImage(systemName: "checkmark.seal.fill") : nil
        viewModel.avatar.bind { [weak self] image in
            DispatchQueue.main.async {
                self?.avatarImageView.image = image
            }
        }
    }
}
