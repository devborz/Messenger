//
//  UserCellViewModel.swift
//  Pangea
//
//  Created by Усман Туркаев on 23.07.2021.
//

import UIKit

class UserCellViewModel {
    var user: User
    
    var username: String {
        return user.username
    }
    
    var avatar: Observable<UIImage> = Observable()
    
    init(with model: User) {
        user = model
        getAvatar(model.c_avatarURL)
    }
    
    func getAvatar(_ url: String?) {
        if let url = url {
            ImageLoader.shared.downloadImageFromURL(url, size: 50) { [weak self] avatar in
                self?.avatar.value = avatar
            }
        } else {
            self.avatar.value = UIImage(systemName: "person.crop.circle")
        }
    }
}

class UserFollowCellViewModel: UserCellViewModel {
    
    var isFollowing: Observable<Bool> = Observable()
    
    override init(with model: User) {
        super.init(with: model)
        DBManager.shared.isCurrentUserFollowingUserWith(model.id) { [weak self] value in
            self?.isFollowing.value = value
        }
    }
    
}
