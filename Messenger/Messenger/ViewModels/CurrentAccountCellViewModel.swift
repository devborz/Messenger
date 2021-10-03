//
//  CurrentAccountCellViewModel.swift
//  Messenger
//
//  Created by Усман Туркаев on 04.10.2021.
//

import UIKit
import RxSwift
import RxCocoa

class CurrentAccountCellViewModel {
    
    var username: BehaviorSubject<String> = .init(value: .init())
    var avatar: BehaviorSubject<UIImage> = .init(value: .init())
    
    private let disposeBag = DisposeBag()
    
    init() {
        DatabaseManager.shared.currentUser.subscribe(onNext: { [weak self] user in
            guard let user = user else { return }
            self?.username.onNext(user.username)
            if let url = user.avatarURL {
                ImageLoader.shared.downloadImageFromURL(url, size: 100) { image in
                    self?.avatar.onNext(image)
                }
            } else {
                self?.avatar.onNext(UIImage(systemName: "person.crop.circle") ?? UIImage())
            }
        }).disposed(by: disposeBag)
    }
}
