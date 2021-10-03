//
//  ChatNodeDataAdapter.swift
//  Pangea
//
//  Created by Усман Туркаев on 27.08.2021.
//

import Foundation
import FirebaseDatabase
import RxCocoa
import RxSwift

class ChatNodeDataAdapter {
    
    weak var node: ChatNode!
    
    var chat: Chat!
    
    var otherUser: User
    
    var otherUserImage: PublishSubject<UIImage> = .init()
    
    var deletedMessages: Set<MessageViewModel> = Set()
    
    var messagesReference: DatabaseReference?

    var isNew: Bool = false
    
    var isReading: Bool = false {
        didSet {
            guard let chat = chat,
                  let viewModel = node.listCellViewModel,
                  let unread = try? viewModel.unread.value() else { return }
            if unread > 0 {
                viewModel.unread.onNext(0)
                ChatsManager.shared.readChat(chat.id)
            }
        }
    }
    
    var isLoadingData: Bool
    
    init(_ chat: Chat, otherUser: User) {
        self.chat = chat
        self.otherUser = otherUser
        isLoadingData = false
        dowloadMessages()
        listenReadState()
        listenOtherUserReadState()
    }
    
    init(getChatWith otherUser: User) {
        self.otherUser = otherUser
        isLoadingData = true
        getChat()
    }

    private func getChat() {
        ChatsManager.shared.getChatWithUser(otherUser.id) { [weak self] chat in
            if let chat = chat {
                self?.chat = chat
                self?.isNew = false
                self?.dowloadMessages()
                self?.listenReadState()
                self?.listenOtherUserReadState()
            } else {
                self?.isNew = true
                self?.listenNewMessages()
                self?.listenReadState()
                self?.listenOtherUserReadState()
            }
            self?.isLoadingData = false
        }
    }
    
    private func dowloadMessages() {
        guard let chat = chat else { return }
        guard let user = try? DatabaseManager.shared.currentUser.value() else { return }
        ChatsManager.shared.getMessagesOfChat(chat) { [weak self] messages in
            guard let self = self else { return }
            var viewModels: [MessageViewModel] = []
            for message in messages {
                viewModels.append(.init(message, sender: message.senderID == user.id ? user : self.otherUser))
            }
            
            self.node.messages = viewModels
            self.node.reload()
            
            self.listenNewMessages()
        }
        
    }
    
    // MARK: Listeners
    
    private func listenNewMessages() {
        let chatID = generateChatIDWithUser(userID: otherUser.id)
        guard let user = try? DatabaseManager.shared.currentUser.value() else { return }
        messagesReference = ChatsManager.shared.listenUpdatesInChat(chatID) { [weak self] messages in
            guard let self = self else { return }
        
            var viewModels: [MessageViewModel] = []
            
            for message in messages {
                guard !self.deletedMessages.contains(where: { value in
                    return value.model.id == message.id
                }) else { continue }
                
                let messageViewModel = MessageViewModel(message, sender: message.senderID == user.id  ? user : self.otherUser)
                viewModels.append(messageViewModel)
            }
            self.node.messages = viewModels
            self.node.shouldUpdate()
        }
    }
    
    private func listenReadState() {
        guard let chat = chat else { return }
        ChatsManager.shared.listenChatReadState(chat.id) { [weak self] unread in
            guard let strongSelf = self else { return }
            strongSelf.chat.unread = strongSelf.isReading ? 0 : unread
            strongSelf.node.listCellViewModel?.unread.onNext(strongSelf.isReading ? 0 : unread)
            ChatsService.shared.countUnreadChats()
            if unread > 0 && strongSelf.isReading {
                ChatsManager.shared.readChat(chat.id)
            }
        }
    }
    
    private func listenOtherUserReadState() {
        guard let chat = chat else { return }
        ChatsManager.shared.listenChatOtherUserReadState(chat) { [weak self] unread in
            guard let strongSelf = self else { return }
            strongSelf.node.isReadByOtherUser = unread == 0
            strongSelf.node.shouldUpdate()
        }
    }
    
    func removeListeners() {
        messagesReference?.removeAllObservers()
    }
    
    func sendMessage(_ viewModel: MessageViewModel, content: MessageContent) {
        if !isLoadingData {
            if isNew {
                let chatID = generateChatIDWithUser(userID: otherUser.id)
                self.chat = .init(id: chatID, created: Date(), otherUserID: otherUser.id, unread: 0)
                ChatsManager.shared.createChatWithUser(chatID, otherUserID: otherUser.id, messageID: viewModel.model.id, content: content) { [weak self] chat in
                    self?.chat = chat
                    self?.isNew = false
                } sendingResult: { state in
                    viewModel.state.onNext(state)
                }
            } else {
                guard let chat = self.chat else { return }
                ChatsManager.shared.sendMessage(messageID: viewModel.model.id, chatID: chat.id, otherUserID: otherUser.id, content: content) { state in
                    viewModel.state.onNext(state)
                }
            }
        }
    }
    
    func deleteMessage(_ viewModel: MessageViewModel) {
        guard let chat = chat else { return }
        ChatsManager.shared.deleteMessageForMe(viewModel.model.id, chat: chat)
        deletedMessages.insert(viewModel)
    }
}
