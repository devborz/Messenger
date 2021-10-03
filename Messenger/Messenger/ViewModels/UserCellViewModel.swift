//
//  UserCellViewModel.swift
//  Pangea
//
//  Created by Усман Туркаев on 23.07.2021.
//

import UIKit
import RxSwift
import RxCocoa

class UserCellViewModel {
    var user: User
    
    var username: String {
        return user.username
    }
    
    var avatar: BehaviorSubject<UIImage> = .init(value: .init())
    
    init(with model: User) {
        user = model
        getAvatar(model.c_avatarURL)
    }
    
    func getAvatar(_ url: String?) {
        if let url = url {
            ImageLoader.shared.downloadImageFromURL(url, size: 50) { [weak self] avatar in
                self?.avatar.onNext(avatar)
            }
        } else {
            self.avatar.onNext(UIImage(systemName: "person.crop.circle")!)
        }
    }
}
