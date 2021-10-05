//
//  DatabaseManager.swift
//  Messenger
//
//  Created by Усман Туркаев on 20.08.2021.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import RxSwift
import RxCocoa

class DatabaseManager {
    
    static var shared = DatabaseManager()
    
    var isLoggedIn: Bool {
        return Auth.auth().currentUser != nil
    }
    
    var currentUserID: String? {
        return Auth.auth().currentUser?.uid
    }
    
    var currentUser = BehaviorSubject<User?>(value: nil)
    
    var listeners: [ListenerRegistration] = []
    
    private var ref = Firestore.firestore()
    
    private init() {
        prepareData {
            ChatsService.shared.prepareData()
        }
        Auth.auth().addStateDidChangeListener { auth, user in
            ChatsService.shared.prepareData()
            ChatsManager.shared.removeActiveListeners()
            DatabaseManager.shared.prepareData {
                ChatsService.shared.prepareData()
            }
        }
    }
    
    
    func prepareData(_ completion: @escaping () -> Void) {
        for listener in listeners {
            listener.remove()
        }
        listeners = []
        listenCurrentUser() { [weak self] user in
            self?.currentUser.onNext(user)
            completion()
        }
    }
}

// MARK: - User

extension DatabaseManager {
    
    func getCurrentUser(_ completion: @escaping (User) -> Void) {
        guard let uid = currentUserID else { return }
        ref.collection("users").document(uid).getDocument { snapshot, error in
            guard error == nil else { return }
            if let data = snapshot?.data() {
                if let user = User(dictionary: data) {
                    completion(user)
                }
            }
        }
    }
    
    func listenCurrentUser(_ completion: @escaping (User) -> Void) {
        guard let uid = currentUserID else { return }
        listenUser(uid) { user in
            completion(user)
        }
    }
    
    func getUsers(_ completion: @escaping ([User]) -> Void) {
        ref.collection("users").getDocuments { snapshot, error in
            guard error == nil else { return }
            if let docs = snapshot?.documents {
                var users: [User] = []
                for doc in docs {
                    if let user = User(dictionary: doc.data()) {
                        users.append(user)
                    }
                }
                completion(users)
            }
        }
    }
    
    func getUser(_ id: String, completion: @escaping (User) -> Void) {
        ref.collection("users").document(id).getDocument { snapshot, error in
            guard error == nil else { return }
            if let data = snapshot?.data() {
                if let user = User(dictionary: data) {
                    completion(user)
                }
            }
        }
    }
    
    func listenUser(_ id: String, completion: @escaping (User) -> Void) {
        let listener = ref.collection("users").document(id).addSnapshotListener { snapshot, error in
            guard error == nil else { return }
            if let data = snapshot?.data() {
                if let user = User(dictionary: data) {
                    completion(user)
                }
            }
        }
        listeners.append(listener)
    }
    
    func createUser(_ username: String, id: String, completion: @escaping (Error?) -> Void) {
        ref.collection("users").document(id).setData([
            "username" : username.lowercased(),
            "id" : id
        ]) { error in
            completion(error)
        }
    }
    
    func setCurrentUserAvatar(_ image: UIImage, completion: (() -> Void)? = nil) {
        guard let uid = currentUserID else {
            return
        }
        StorageManager.shared.setCurrentUserAvatar(image) { url in
            self.ref.collection("users").document(uid).updateData([
                "avatarURL" : url.fullSizeURL,
                "c_avatarURL" : url.compressedURL
            ]) { error in
                guard error == nil else { return }
                completion?()
            }
        }
    }
    
    func removeCurrentUserAvatar() {
        guard let uid = currentUserID else {
            return
        }
        ref.collection("users").document(uid).updateData([
            "avatarURL" : FieldValue.delete(),
            "c_avatarURL" : FieldValue.delete()
        ])
    }
}
