//
//  UserCell.swift
//  Pangea
//
//  Created by  AdamRouss🐺 on 18.03.2021.
//

import UIKit
import RxSwift

class UserCell: UITableViewCell {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var verifiedImageView: UIImageView!
    
    var viewModel: UserCellViewModel!
    
    private var disposeBag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        avatarImageView.tintColor = avatarTintColor
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        avatarImageView.image = nil
        usernameLabel.text = nil
        viewModel = nil
        disposeBag = DisposeBag()
    }

    func setup(_ viewModel: UserCellViewModel) {
        self.viewModel = viewModel
        usernameLabel.text = viewModel.username
        viewModel.avatar.subscribe(onNext: { [weak self] image in
            DispatchQueue.main.async {
                self?.avatarImageView.image = image
            }
        }).disposed(by: disposeBag)
    }
}
