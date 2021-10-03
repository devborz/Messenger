//
//  ChatsListViewModel.swift
//  Pangea
//
//  Created by Усман Туркаев on 15.08.2021.
//

import UIKit
import RxSwift
import RxCocoa

protocol ChatsServiceDelegate: AnyObject {
    func update()
    
    func reload()
}

enum ChatsListSection {
    case allChats
}

final class ChatsService {
    
    weak var delegate: ChatsServiceDelegate?
    
    var nodes: [ChatNode] = []
    
    var lastVersion: [ChatNode] = []
    
    var presentingChats: [ChatCellViewModel] {
        return prepareList()
    }
    
    var countOfUnreadChats: BehaviorSubject<Int> = .init(value: 0)
    
    private var deletedNodes: [ChatNode] = []
    
    var didFirstLoad = false
    
    static var shared = ChatsService()
    
    private init() { }
    
    func prepareData() {
        didFirstLoad = false
        nodes.removeAll()
        deletedNodes.removeAll()
        if DatabaseManager.shared.isLoggedIn {
            ChatsManager.shared.getAllChats { [weak self] chats in
                var nodes: [ChatNode] = []
                for chat in chats {
                    nodes.append(.init(chat))
                }
                self?.nodes = nodes
                self?.didFirstLoad = true
                self?.performReload()
                self?.listenNewChats()
                self?.countUnreadChats()
            }
        }
    }
    
    func listenNewChats() {
        ChatsManager.shared.listenNewChats { [weak self] chats in
            guard let strongSelf = self else { return }
            
            var newNodes: [ChatNode] = []
            
            for chat in chats {
                guard !strongSelf.deletedNodes.contains(where: { value in
                    
                    guard let lastMessageID = try? value.listCellViewModel.lastMessage.value()?.id else { return false }
                    return lastMessageID == chat.lastMessage.id
                }) else { continue }
                
                newNodes.append(.init(chat))
            }
            
            let oldSet = Set(strongSelf.lastVersion.map(\.listCellViewModel))
            let newSet = Set(newNodes.map(\.listCellViewModel))
            if oldSet != newSet {
                strongSelf.nodes = newNodes
                strongSelf.update()
            }
            strongSelf.countUnreadChats()
        }
    }
    
    func countUnreadChats() {
        var count = 0
        for node in nodes {
            if node.chat.unread > 0 {
                count += 1
            }
        }
        countOfUnreadChats.onNext(count)
    }
    
    func changeLastMessage(_ node: ChatNode, message: Message) {
        guard let viewModel = node.listCellViewModel else { return }
        viewModel.lastMessage.onNext(message)
        update()
    }
    
    func hideNode(_ node: ChatNode) {
        nodes.removeAll { value in
            return node.chat.id == value.chat.id
        }
        update()
        countUnreadChats()
    }
    
    func deleteChat(_ index: Int) {
        let chatNode = lastVersion[index]
        nodes.removeAll { node in
            return node.chat.id == chatNode.chat.id
        }
        update()
        chatNode.removeListeners()
        deletedNodes.append(chatNode)
        if let chat = chatNode.chat {
            ChatsManager.shared.deleteChat(chat)
        }
    }

    func getChatNode(_ user: User) -> ChatNode {
        for node in nodes {
            if node.otherUser.id == user.id {
                return node
            }
        }
        return .init(getChatWith: user)
    }
    
    func performReload() {
        delegate?.reload()
    }
    
    func update() {
        delegate?.update()
    }
    
    func prepareList() -> [ChatCellViewModel] {
        var nodes: [ChatNode] = []
        for node in self.nodes {
            if let listCellViewModel = node.listCellViewModel {
                nodes.append(node)
            }
        }
        nodes.sort { lhs, rhs in
            return lhs.listCellViewModel > rhs.listCellViewModel
        }
        lastVersion = nodes
        return nodes.map(\.listCellViewModel)
    }
}
