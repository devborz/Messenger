//
//  ChatCellViewModel.swift
//  Messenger
//
//  Created by Усман Туркаев on 21.08.2021.
//

import UIKit
import RxSwift
import RxCocoa

final class ChatCellViewModel: Hashable, Equatable, Comparable {
    static func < (lhs: ChatCellViewModel, rhs: ChatCellViewModel) -> Bool {
        guard let lhsMessage = try? lhs.lastMessage.value(),
              let rhsMessage = try? rhs.lastMessage.value() else { return false }
        return lhsMessage.created.timeIntervalSince1970 < rhsMessage.created.timeIntervalSince1970
    }
    
    static func == (lhs: ChatCellViewModel, rhs: ChatCellViewModel) -> Bool {
        return lhs.model.id == rhs.model.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(model.id)
    }
    
    var model: Chat
    
    var otherUserImage = BehaviorSubject<UIImage>(value: .init())
    
    var otherUserInfo: User
    
    var lastMessage = BehaviorSubject<Message?>(value: nil)
    
    var unread: BehaviorSubject<Int> = BehaviorSubject(value: 0)
    
    init(_ data: ChatData) {
        self.model = data.chat
        self.otherUserInfo = data.otherUser
        self.lastMessage.onNext(data.lastMessage)
        self.unread.onNext(model.unread)
        if let url = data.otherUser.c_avatarURL {
            ImageLoader.shared.downloadImageFromURL(url, size: 50) { [weak self] image in
                self?.otherUserImage.onNext(image)
            }
        } else {
            self.otherUserImage.onNext(UIImage(systemName: "person.crop.circle") ?? UIImage())
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
