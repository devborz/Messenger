//
//  ChatCellViewModel.swift
//  Messenger
//
//  Created by Усман Туркаев on 21.08.2021.
//

import UIKit

final class ChatCellViewModel: Hashable, Equatable, Comparable {
    static func < (lhs: ChatCellViewModel, rhs: ChatCellViewModel) -> Bool {
        return (lhs.lastMessage.value?.created ?? lhs.model.created).timeIntervalSince1970 <
            (rhs.lastMessage.value?.created ?? rhs.model.created).timeIntervalSince1970
    }
    
    static func == (lhs: ChatCellViewModel, rhs: ChatCellViewModel) -> Bool {
        return lhs.model.id == rhs.model.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(model.id)
    }
    
    var model: Chat
    
    var otherUserImage: Observable<UIImage> = Observable()
    
    var otherUserInfo: User
    
    var lastMessage: Observable<Message> = Observable()
    
    var unread: DefinedObservable<Int> = DefinedObservable(0)
    
    init(_ data: ChatData) {
        self.model = data.chat
        self.otherUserInfo = data.otherUser
        self.lastMessage.value = data.lastMessage
        self.unread.value = model.unread
        if let url = data.otherUser.c_avatarURL {
//            ImageLoader.shared.downloadImageFromURL(url, size: 50) { [weak self] image in
//                self?.otherUserImage.value = image
//            }
        } else {
            self.otherUserImage.value = UIImage(systemName: "person.crop.circle")
        }
    }
    
    func formatMessageDate(_ messageDate: Date) -> String {
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd:MM:yyyy"
        if dateFormatter.string(from: currentDate) == dateFormatter.string(from: messageDate) {
            dateFormatter.dateFormat = "HH:mm"
            return dateFormatter.string(from: messageDate)
        } else {
            dateFormatter.dateFormat = "dd.MM"
            return dateFormatter.string(from: messageDate)
        }
    }
}
