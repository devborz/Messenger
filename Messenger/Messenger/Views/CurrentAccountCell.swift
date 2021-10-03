//
//  CurrentAccountCell.swift
//  Messenger
//
//  Created by Усман Туркаев on 03.10.2021.
//

import UIKit
import RxSwift

class CurrentAccountCell: UITableViewCell {
    
    var viewModel: CurrentAccountCellViewModel?
    
    var disposeBag = DisposeBag()
    
    @IBOutlet weak var avatarView: UIImageView!
    
    @IBOutlet weak var usernameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        avatarView.tintColor = avatarTintColor
        avatarView.layer.cornerRadius = 50
        avatarView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        viewModel = nil
    }
    
    func setup() {
        viewModel = .init()
        viewModel?.username.subscribe(onNext: { [weak self] username in
            DispatchQueue.main.async {
                self?.usernameLabel.text = username
            }
        }).disposed(by: disposeBag)
        viewModel?.avatar.subscribe(onNext: { [weak self] image in
            DispatchQueue.main.async {
                self?.avatarView.image = image
            }
        }).disposed(by: disposeBag)
    }
    
}
