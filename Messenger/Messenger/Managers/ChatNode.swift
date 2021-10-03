//
//  ChatViewModel.swift
//  Pangea
//
//  Created by Усман Туркаев on 16.08.2021.
//

import UIKit
import FirebaseDatabase

struct ChatUpdate {
    
    enum UpdateType {
        case add, delete
    }
    
    var type: UpdateType
    
    var content: ChatContent
}

protocol ChatNodeDelegate: AnyObject {
    func reloadChat()
    
    func updateChat()
}

class ChatNode {
    
    weak var delegate: ChatNodeDelegate?
    
    private let dataAdapter: ChatNodeDataAdapter
    
    let seenIndicatorViewModel = SeenIndicatorViewModel()
    
    var isReadByOtherUser: Bool = false
    
    var listCellViewModel: ChatCellViewModel!
    
    var messages: [MessageViewModel] = []
    
    var chatContent: [ChatContent] {
        return prepareContent(messages)
    }
    
    var otherUser: User {
        return dataAdapter.otherUser
    }
    
    var chat: Chat! {
        return dataAdapter.chat
    }
    
    init(getChatWith otherUser: User) {
        dataAdapter = .init(getChatWith: otherUser)
        dataAdapter.node = self
    }
    
    init(_ data: ChatData) {
        listCellViewModel = .init(data)
        dataAdapter = .init(data.chat, otherUser: data.otherUser)
        dataAdapter.node = self
    }
    
    func removeListeners() {
        dataAdapter.removeListeners()
    }
    
    // MARK: - DataAdapter and UpdateAdapter connection methods
    
    func startReading() {
        dataAdapter.isReading = true
    }
    
    func endReading() {
        dataAdapter.isReading = false
    }
    
    func reload() {
        delegate?.reloadChat()
    }
    
    func shouldUpdate() {
        if let lastMessage = messages.first?.model  {
            if let previousLastMessage =  try? listCellViewModel?.lastMessage.value() {
                if lastMessage.id != previousLastMessage.id {
                    ChatsService.shared.changeLastMessage(self, message: lastMessage)
                }
            }
        } else {
            if listCellViewModel?.lastMessage.value != nil {
                ChatsService.shared.hideNode(self)
            }
        }
        delegate?.updateChat()
    }
    
    // MARK: Work with messages
    
    func deleteMessage(_ viewModel: MessageViewModel) {
        messages.removeAll { value in
            return value.model.id == viewModel.model.id
        }
        shouldUpdate()
        dataAdapter.deleteMessage(viewModel)
    }
    
    func sendMessage(_ messageContent: MessageContent) {
        let id = UUID().uuidString
        guard let user = try? DatabaseManager.shared.currentUser.value() else { return }
        
        let messageViewModel = MessageViewModel(id, newMessage: messageContent, sender: user)
        messages.insert(messageViewModel, at: 0)
        isReadByOtherUser = false
        shouldUpdate()
        dataAdapter.sendMessage(messageViewModel, content: messageContent)
    }
    
    func needSeenIndicator() -> Bool {
        guard let lastMessage = messages.first else {
            return false
        }
        return isReadByOtherUser && lastMessage.type == .outgoing
    }
    
    func prepareContent(_ messages: [MessageViewModel]) -> [ChatContent] {
        var sortedMessages: [ChatContent] = []
        guard !messages.isEmpty else { return [] }
        let reversed = messages.reversed()
        sortedMessages.append(.init(type: .header(value: .init(date: messages.last!.model.created))))
        var messageBefore = reversed.first!
        for message in reversed {
            if !haveEqualSectionDates(lhs: messageBefore, rhs: message) {
                sortedMessages.append(.init(type: .header(value: .init(date: message.model.created))))
            }
            sortedMessages.append(.init(type: .message(value: message)))
            messageBefore = message
        }
        
        if needSeenIndicator() {
            sortedMessages.append(.init(type: .seenIndicator(value: seenIndicatorViewModel)))
        }
        return sortedMessages.reversed()
    }
}

func formatSectionDate(_ date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "ddMMyyyy"
    return dateFormatter.string(from: date)
}

func haveEqualSectionDates(lhs: MessageViewModel, rhs: MessageViewModel) -> Bool {
    return formatSectionDate(lhs.model.created) == formatSectionDate(rhs.model.created)
}
