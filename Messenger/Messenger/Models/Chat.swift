//
//  Chat.swift
//  Pangea
//
//  Created by  AdamRouss🐺 on 22.02.2021.
//

import UIKit

final class ChatData {
    var chat: Chat!
    
    var otherUser: User!
    
    var lastMessage: Message!
    
    init(chat: Chat, user: User, lastMessage: Message) {
        self.chat = chat
        self.otherUser = user
        self.lastMessage = lastMessage
    }
}

func generateChatIDWithUser(userID: String) -> String {
    guard let uid = DatabaseManager.shared.currentUserID else {
        fatalError("User is not authorized")
        return ""
    }
    if uid < userID {
        return "\(uid)-\(userID)"
    } else {
        return "\(userID)-\(uid)"
    }
}

struct Chat: Hashable {
    
    static func == (lhs: Chat, rhs: Chat) -> Bool {
        return lhs.id == rhs.id
    }
    
    var id: String
    
    var created: Date
   
    var otherUserID: String
    
    var unread: Int
    
    init(id: String, created: Date, otherUserID: String, unread: Int) {
        self.id = id
        self.created = created
        self.otherUserID = otherUserID
        self.unread = unread
    }
}

extension Chat {
    init?(dictionary: [String : Any]) {
        guard let uid = DatabaseManager.shared.currentUserID else { return nil }
        
        guard let id = dictionary["id"] as? String,
              let chatUsers = dictionary["users"] as? [String],
              let createdDateStamp = dictionary["created"] as? TimeInterval,
              let unread = dictionary["unread"] as? Int else { return nil }
        
        var otherUserID = ""
        if chatUsers[0] == uid {
            otherUserID = chatUsers[1]
        } else {
            otherUserID = chatUsers[0]
        }
        
        let created = Date(timeIntervalSince1970: createdDateStamp / 1000)
        self.init(id: id, created: created, otherUserID: otherUserID, unread: unread)
    }
}
