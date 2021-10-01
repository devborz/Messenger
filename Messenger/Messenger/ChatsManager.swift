//
//  ChatsManager.swift
//  Pangea
//
//  Created by  AdamRouss🐺 on 08.05.2021.
//

import Foundation
import FirebaseDatabase

final class ChatsManager {
    
    static var shared = ChatsManager()
    
    var ref = Database.database().reference()
    
    private var userID: String? {
        return DatabaseManager.shared.currentUserID
    }
    
    var referencesOfListeners: [DatabaseReference] = []
    
    private init() { }
    
    func removeActiveListeners() {
        for reference in referencesOfListeners {
            reference.removeAllObservers()
        }
        referencesOfListeners = []
    }
    
    // MARK: - Chats
    
    /// Fetches chat with other user
    func getChatWithUser(_ id: String, completion: @escaping (Chat?) -> Void) {
        let chatID = generateChatIDWithUser(userID: id)
        self.getChat(chatID, completion: { chat in
            completion(chat)
        })
    }
    
    /// Created new chat with user
    func createChatWithUser(_ chatID: String, otherUserID: String, messageID: String, content: MessageContent, chatCreated: @escaping (Chat) -> Void, sendingResult: @escaping (MessageState) -> Void) {
        guard let uid = userID else { return }
        let chatInfo: [String : Any] = [
            "id" : chatID,
            "users" : [uid, otherUserID],
            "created" : ServerValue.timestamp(),
            "unread" : 0
        ]
        ref.child("chats").child(chatID).child(otherUserID).child("info").setValue(chatInfo)
        ref.child("chats").child(chatID).child(uid).child("info").setValue(chatInfo, withCompletionBlock: { error, ref in
            guard error == nil else {
              sendingResult(.errorOccured)
              return
            }
            self.getChat(chatID) { chat in
              if let chat = chat {
                  chatCreated(chat)
              }
            }
            self.sendMessage(messageID: messageID, chatID: chatID, otherUserID: otherUserID, content: content) { state in
                sendingResult(state)
            }
        })
        ref.child("users").child(uid).child("chats").child(chatID).setValue(["timestamp" : ServerValue.timestamp()])
        ref.child("users").child(otherUserID).child("chats").child(chatID).setValue(["timestamp" : ServerValue.timestamp()])
    }
    
    
    /// Fetches all user chats
    func getAllChats(_ completion: @escaping ([ChatData]) -> Void) {
        guard let uid = userID else { return }
        ref.child("users").child(uid).child("chats").observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let dict = snapshot.value as? [String : Any] else {
                completion([])
                return
            }
            var chats: [ChatData] = []
            let ids = Array(dict.keys)
            
            var tasksCount = ids.count
            for id in ids {
                self?.getChatData(id, completion: { data in
                    if let data = data {
                        chats.append(data)
                    }
                    tasksCount -= 1
                    if tasksCount == 0 {
                        chats.sort { lhs, rhs in
                            return lhs.lastMessage.created.timeIntervalSince1970 >
                                rhs.lastMessage.created.timeIntervalSince1970
                        }
                        completion(chats)
                    }
                })
            }
        }
    }
    
    /// Listens updates in chats
    func listenNewChats(_ completion: @escaping ([ChatData]) -> Void) {
        guard let uid = userID else { return }
        let reference = ref.child("users").child(uid).child("chats")
        referencesOfListeners.append(reference)
        reference.observe(.value) { [weak self] snapshot in
            guard let dict = snapshot.value as? [String : Any] else {
                completion([])
                return
            }
            var chats: [ChatData] = []
            let ids = Array(dict.keys)
            
            var tasksCount = ids.count
            for id in ids {
                self?.getChatData(id, completion: { data in
                    if let data = data {
                        chats.append(data)
                    }
                    tasksCount -= 1
                    if tasksCount == 0 {
                        chats.sort { lhs, rhs in
                            return lhs.lastMessage.created.timeIntervalSince1970 >
                                rhs.lastMessage.created.timeIntervalSince1970
                        }
                        completion(chats)
                    }
                })
            }
        }
    }
    
    func getChatData(_ id: String, completion: @escaping (ChatData?) -> Void) {
        guard let uid = DatabaseManager.shared.currentUserID else { return }
        ref.child("chats").child(id).child(uid).child("info").observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let dict = snapshot.value as? [String : Any] else {
                completion(nil)
                return
            }
            guard let chat = Chat(dictionary: dict) else {
                completion(nil)
                return
            }
            self?.getLastMessageInChat(id, completion: { message in
                guard let message = message else {
                    completion(nil)
                    return
                }
                DatabaseManager.shared.getUser(chat.otherUserID) { user in
                    completion(.init(chat: chat, user: user, lastMessage: message))
                }
            })
        }
    }
    
    func getChat(_ id: String, completion: @escaping (Chat?) -> Void) {
        guard let uid = DatabaseManager.shared.currentUserID else { return }
        ref.child("chats").child(id).child(uid).child("info").observeSingleEvent(of: .value) { snapshot in
            guard let dict = snapshot.value as? [String : Any] else {
                completion(nil)
                return
            }
            completion(.init(dictionary: dict))
        }
    }
    
    func listenChatOtherUserReadState(_ chat: Chat, completion: @escaping (Int) -> Void) {
        let reference = ref.child("chats").child(chat.id).child(chat.otherUserID).child("info").child("unread")
        referencesOfListeners.append(reference)
        reference.observe(.value) { snapshot in
            guard let value = snapshot.value as? Int else { return }
            completion(value)
        }
    }
    
    func listenChatReadState(_ chatID: String, completion: @escaping (Int) -> Void) {
        guard let uid = DatabaseManager.shared.currentUserID else { return }
        let reference = ref.child("chats").child(chatID).child(uid).child("info").child("unread")
        referencesOfListeners.append(reference)
        reference.observe(.value) { snapshot in
            guard let value = snapshot.value as? Int else { return }
            completion(value)
        }
    }
    
    func readChat(_ chatID: String) {
        guard let uid = DatabaseManager.shared.currentUserID else { return }
        ref.child("chats").child(chatID).child(uid).child("info").child("unread").setValue(0)
    }
    
    // MARK: - Messages
    
    /// Gets last message in chat
    func getLastMessageInChat(_ id: String, completion: @escaping (Message?) -> Void) {
        guard let uid = DatabaseManager.shared.currentUserID else { return }
        ref.child("chats").child(id).child(uid).child("messages").queryOrdered(byChild: "created").queryLimited(toLast: 1).observeSingleEvent(of: .value) { snapshot in
            guard snapshot.childrenCount == 1 else {
                completion(nil)
                return
            }
            for child in snapshot.children {
                guard let childSnapshot = child as? DataSnapshot else {
                    completion(nil)
                    return
                }
                guard let dict = childSnapshot.value as? [String: Any] else {
                    completion(nil)
                    return
                }
                completion(Message(dictionary: dict))
            }
        }
    }
    
    /// listen last message in chat
    func listenLastMessageInChat(_ id: String, completion: @escaping (Message?) -> Void) {
        guard let uid = userID else { return }
        let reference = ref.child("chats").child(id).child(uid).child("messages")
        referencesOfListeners.append(reference)
        reference.queryOrdered(byChild: "created").queryLimited(toLast: 1).observe(.value) { snapshot in
            guard snapshot.childrenCount == 1 else {
                completion(nil)
                return
            }
            for child in snapshot.children {
                guard let childSnapshot = child as? DataSnapshot else {
                    completion(nil)
                    return
                }
                guard let dict = childSnapshot.value as? [String: Any] else {
                    completion(nil)
                    return
                }
                completion(Message(dictionary: dict))
            }
        }
    }

    /// Sends message
    func sendMessage(messageID: String, chatID: String, otherUserID: String, content: MessageContent, completion: @escaping (MessageState) -> Void) {
        guard let uid = userID else { return }
        var data: [String: Any] = [:]
        data["id"] = messageID
        data["senderID"] = uid
        data["created"] = ServerValue.timestamp()
        data["updated"] = ServerValue.timestamp()
        data["deleted"] = "false"
        switch content {
        case .text(text: let text):
            data["type"] = "text"
            data["text"] = text
            ref.child("chats").child(chatID).child(uid).child("messages").child(messageID).setValue(data, withCompletionBlock: { error, dataRef in
                guard error == nil else {
                    completion(.errorOccured)
                    return
                }
                completion(.sent)
            })
            ref.child("chats").child(chatID).child(otherUserID).child("messages").child(messageID).setValue(data)
            ref.child("chats").child(chatID).child(otherUserID).child("info").child("unread").setValue(ServerValue.increment(_:)(1))
            ref.child("users").child(uid).child("chats").child(chatID).setValue(["timestamp" : ServerValue.timestamp()])
            ref.child("users").child(otherUserID).child("chats").child(chatID).setValue(["timestamp" : ServerValue.timestamp()])
        case .image(image: let image):
            data["type"] = "image"
            StorageManager.shared.uploadMessagePhoto(image, with: messageID) { url in
                data["imageURL"] = url
                
                self.ref.child("chats").child(chatID).child(uid).child("messages").child(messageID).setValue(data, withCompletionBlock: { error, dataRef in
                    guard error == nil else {
                        completion(.errorOccured)
                        return
                    }
                    completion(.sent)
                })
                self.ref.child("chats").child(chatID).child(otherUserID).child("messages").child(messageID).setValue(data)
                self.ref.child("chats").child(chatID).child(otherUserID).child("info").child("unread").setValue(ServerValue.increment(_:)(1))
                self.ref.child("users").child(uid).child("chats").child(chatID).setValue(["timestamp" : ServerValue.timestamp()])
                self.ref.child("users").child(otherUserID).child("chats").child(chatID).setValue(["timestamp" : ServerValue.timestamp()])
            }
        case .location(location: let location):
            data["type"] = "location"
            data["location"] = location.dictionary
            
            ref.child("chats").child(chatID).child(uid).child("messages").child(messageID).setValue(data, withCompletionBlock: { error, dataRef in
                guard error == nil else {
                    completion(.errorOccured)
                    return
                }
                completion(.sent)
            })
            ref.child("chats").child(chatID).child(otherUserID).child("messages").child(messageID).setValue(data)
            ref.child("chats").child(chatID).child(otherUserID).child("info").child("unread").setValue(ServerValue.increment(_:)(1))
            ref.child("users").child(uid).child("chats").child(chatID).setValue(["timestamp" : ServerValue.timestamp()])
            ref.child("users").child(otherUserID).child("chats").child(chatID).setValue(["timestamp" : ServerValue.timestamp()])
        }
    }
    
    func deleteMessageForMe(_ messageID: String, chat: Chat) {
        guard let uid = userID else { return }
        
        ref.child("chats").child(chat.id).child(uid).child("messages").child(messageID).removeValue()
    }
    
    func deleteChat(_ chat: Chat) {
        guard let uid = userID else { return }
        
        ref.child("chats").child(chat.id).child(uid).child("messages").removeValue()
        ref.child("users").child(uid).child("chats").child(chat.id).child("timestamp").setValue(ServerValue.timestamp())
    }
    
    func getMessagesOfChat(_ chat: Chat, completion: @escaping ([Message]) -> Void) {
        guard let uid = userID else { return }
        ref.child("chats").child(chat.id).child(uid).child("messages").observeSingleEvent(of: .value) { snapshot in
            guard let dict = snapshot.value as? [String : Any] else {
                completion([])
                return
            }
            let ids: [String] = Array(dict.keys)
            var messages: [Message] = []
            for id in ids {
                if let data = dict[id] as? [String : Any] {
                    if let message = Message(dictionary: data) {
                        messages.append(message)
                    }
                }
            }
            messages.sort { lhs, rhs in
                return lhs.created.timeIntervalSince1970 > rhs.created.timeIntervalSince1970
            }
            completion(messages)
        }
    }
    
    func listenUpdatesInChat(_ chatID: String, completion: @escaping ([Message]) -> Void) -> DatabaseReference? {
        guard let uid = userID else { return nil }
        let reference = ref.child("chats").child(chatID).child(uid).child("messages")
        referencesOfListeners.append(reference)
        reference.observe(.value) { snapshot in
            guard let dict = snapshot.value as? [String : Any] else {
                completion([])
                return
            }
            let ids: [String] = Array(dict.keys)
            var messages: [Message] = []
            for id in ids {
                if let data = dict[id] as? [String : Any] {
                    if let message = Message(dictionary: data) {
                        messages.append(message)
                    }
                }
            }
            messages.sort { lhs, rhs in
                return lhs.created.timeIntervalSince1970 > rhs.created.timeIntervalSince1970
            }
            completion(messages)
        }
        return reference
    }
}
