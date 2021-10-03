//
//  ChatTopAvatarView.swift
//  Pangea
//
//  Created by Усман Туркаев on 19.08.2021.
//

import UIKit
import RxSwift
import RxCocoa

final class ChatTopAvatarView: UIView {
    
    let viewModel: ChatTopAvatarViewModel
    
    let imageView = UIImageView()
    
    private let disposeBag = DisposeBag()

    init(_ viewModel: ChatTopAvatarViewModel) {
        self.viewModel = viewModel
        super.init(frame: CGRect(x: 0, y: 0, width: 80, height: 35))
        viewModel.avatar.subscribe(onNext: { [weak self] image in
            DispatchQueue.main.async {
                self?.imageView.image = image
            }
        }).disposed(by: disposeBag)
        
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
    
    var avatar: PublishSubject<UIImage> = .init()
    
    init(url: String?) {
        if let url = url {
            ImageLoader.shared.downloadImageFromURL(url, size: 50) { [weak self] image in
                self?.avatar.onNext(image)
            }
        }
    }
}
