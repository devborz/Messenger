//
//  ChatTopAvatarView.swift
//  Pangea
//
//  Created by Усман Туркаев on 19.08.2021.
//

import UIKit

final class ChatTopAvatarView: UIView {
    
    let viewModel: ChatTopAvatarViewModel
    
    let imageView = UIImageView()

    init(_ viewModel: ChatTopAvatarViewModel) {
        self.viewModel = viewModel
        super.init(frame: CGRect(x: 0, y: 0, width: 80, height: 35))
        viewModel.avatar.bind { [weak self] image in
            DispatchQueue.main.async {
                self?.imageView.image = image
            }
        }
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(imageView)
        imageView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        imageView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 35).isActive = true
        imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor).isActive = true
        
        imageView.layer.cornerRadius = 17.5
        imageView.clipsToBounds = true
        imageView.backgroundColor = .secondarySystemBackground
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class ChatTopAvatarViewModel {
    
    var avatar: Observable<UIImage> = Observable()
    
    init(url: String?) {
        if let url = url {
//            ImageLoader.shared.downloadImageFromURL(url, size: 50) { [weak self] image in
//                self?.avatar.value = image
//            }
        }
    }
}
