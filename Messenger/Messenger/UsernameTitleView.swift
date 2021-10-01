//
//  ProfileTitleView.swift
//  Pangea
//
//  Created by Усман Туркаев on 29.07.2021.
//

import UIKit

protocol UsernameTitleViewDelegate: AnyObject {
    func titleViewTapped(userID: String)
}

final class UsernameTitleView: UIView {
    
    weak var delegate: UsernameTitleViewDelegate?
    
    var viewModel: UsernameTitleViewModel
    
    let usernameLabel = UILabel()
    
    let verifiedImageView = UIImageView()
    
    var imageViewConstraint: NSLayoutConstraint!
    
    var tapGestureRecognizer: UITapGestureRecognizer!

    init(_ viewModel: UsernameTitleViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTap))
        addGestureRecognizer(tapGestureRecognizer)
        
        verifiedImageView.tintColor = .systemBlue
        usernameLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        verifiedImageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(usernameLabel)
        addSubview(verifiedImageView)
        
        usernameLabel.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        usernameLabel.topAnchor.constraint(equalTo: topAnchor).isActive = true
        usernameLabel.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        verifiedImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        verifiedImageView.leftAnchor.constraint(equalTo: usernameLabel.rightAnchor, constant: 2).isActive = true
        verifiedImageView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        imageViewConstraint = verifiedImageView.heightAnchor.constraint(equalToConstant: 16)
        imageViewConstraint.isActive = true
        verifiedImageView.widthAnchor.constraint(equalTo: verifiedImageView.heightAnchor).isActive = true
        verifiedImageView.contentMode = .scaleAspectFill
        
        
        viewModel.username.bind { [weak self] value in
            self?.usernameLabel.text = value
        }
        viewModel.isVerified.bind { [weak self] value in
            guard let value = value else { return }
            self?.verifiedImageView.image = value ? UIImage(systemName: "checkmark.seal.fill") : nil
            self?.imageViewConstraint.constant = value ? 16 : 0
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc
    func didTap() {
        delegate?.titleViewTapped(userID: viewModel.userID)
    }
}

class UsernameTitleViewModel {
    
    var userID: String

    var username: Observable<String> = Observable()
    
    var isVerified: Observable<Bool> = Observable()
    
    init(_ userID: String) {
        self.userID = userID
        DatabaseManager.shared.listenUser(userID) { user in
            self.username.value = user.username
            self.isVerified.value = user.isVerified
        }
    }
    
    init(_ user: User) {
        userID = user.id
        username.value = user.username
//        isVerified.value = user.isVerified
    }
}
