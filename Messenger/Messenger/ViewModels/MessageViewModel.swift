//
//  MessageViewModel.swift
//  Pangea
//
//  Created by Усман Туркаев on 16.08.2021.
//

import UIKit
import RxSwift

enum MessageState {
    case normal
    case sending
    case sent
    case errorOccured
}
enum ChatSection {
    case section
}

enum ChatContentType: Hashable, Equatable {
    
    case message(value: MessageViewModel)
    case header(value: MessagesDateHeaderViewModel)
    case seenIndicator(value: SeenIndicatorViewModel)
}

struct ChatContent: Hashable, Equatable {
    
    var type: ChatContentType
    
    static func == (lhs: ChatContent, rhs: ChatContent) -> Bool {
        switch (lhs.type, rhs.type) {
        case (.message(value: let lhsMessage), .message(value: let rhsMessage)):
            return lhsMessage.model.id == rhsMessage.model.id
        case (.header(value: let lhsValue), .header(value: let rhsValue)):
            return lhsValue.title == rhsValue.title
        case (.seenIndicator(value: _), .seenIndicator(value: _)):
            return true
        default: return false
        }
    }
    
    func hash(into hasher: inout Hasher) {
        switch type {
        case .message(value: let value):
            hasher.combine(value.model.id)
        case .header(value: let value):
            hasher.combine(value.title)
        case .seenIndicator(value: let value):
            hasher.combine(value.isSeen)
        }
    }
}

struct SeenIndicatorViewModel: Hashable {
    static func == (lhs: SeenIndicatorViewModel, rhs: SeenIndicatorViewModel) -> Bool {
        return true
    }
    
    let isSeen = true
}

final class MessageViewModel: Hashable {
    static func == (lhs: MessageViewModel, rhs: MessageViewModel) -> Bool {
        return lhs.model.id == rhs.model.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(model.id)
    }
    
    var model: Message
    
    var type: MessageKind
    
    var senderAvatar: BehaviorSubject<UIImage> = .init(value: .init())
    
    var messagePhoto: BehaviorSubject<UIImage?> = .init(value: nil)
    
    private let disposeBag = DisposeBag()
    
    var eventIsNotAvailable = false
    
    var messageLocation: Location?
    
    var state: BehaviorSubject<MessageState> = .init(value: .normal)
    
    init(_ model: Message, sender: User) {
        self.model = model
        if model.senderID == DatabaseManager.shared.currentUserID ?? "" {
            type = .outgoing
        } else {
            type = .incoming
        }
        switch model.attachment {
        case .empty:
            break
        case .location(location: let location):
            messageLocation = location
        case .image(url: let url):
            ImageLoader.shared.downloadImageFromURL(url) { [weak self] image in
                self?.messagePhoto.onNext(image)
            }
        }
        if let url = sender.c_avatarURL {
            ImageLoader.shared.downloadImageFromURL(url, size: 50) { [weak self] image in
                self?.senderAvatar.onNext(image)
            }
        } else {
            self.senderAvatar.onNext(UIImage(systemName: "person.crop.circle") ?? UIImage())
        }
    }
    
    init(_ id: String, newMessage: MessageContent, sender: User) {
        let uid = DatabaseManager.shared.currentUserID ?? ""
        state.onNext(.sending)
        type = .outgoing
        let date = Date()
        switch newMessage {
        case .text(text: let text):
            model = .init(id: id, type: .text, text: text, created: date, updated: date, senderID: uid, attachment: .empty)
        case .image(image: let image):
            model = .init(id: id, type: .image, text: "", created: date, updated: date, senderID: uid, attachment: .image(url: ""))
            messagePhoto.onNext(image)
        case .location(location: let location):
            model = .init(id: id, type: .location, text: "", created: date, updated: date, senderID: uid, attachment: .location(location: location))
            messageLocation = location
        }
        if let url = sender.c_avatarURL {
            ImageLoader.shared.downloadImageFromURL(url, size: 50) { [weak self] image in
                self?.senderAvatar.onNext(image)
            }
        } else {
            self.senderAvatar.onNext(UIImage(systemName: "person.crop.circle") ?? UIImage())
        }
    }
}

struct MessagesDateHeaderViewModel: Hashable, Equatable {
    
    var date: Date
    
    var title: String
    
    init(date: Date) {
        self.date = date
        self.title = formatChatHeaderDate(date)
    }
}
