//
//  DatabaseManager.swift
//  Messenger
//
//  Created by Усман Туркаев on 20.08.2021.
//

import UIKit
import Firebase

class DatabaseManager {
    
    static var shared = DatabaseManager()
    
    var isLoggedIn: Bool {
        return Auth.auth().currentUser != nil
    }
    
    var currentUserID: String? {
        return Auth.auth().currentUser?.uid
    }
    
    var currentUser: User?
    
    private var ref = Firestore.firestore()
    
    private init() {
        prepareData {
            ChatsService.shared.prepareData()
        }
        Auth.auth().addStateDidChangeListener { auth, user in
            ChatsManager.shared.removeActiveListeners()
            DatabaseManager.shared.prepareData {
                ChatsService.shared.prepareData()
            }
        }
    }
    
    
    func prepareData(_ completion: @escaping () -> Void) {
        getCurrentUser { user in
            self.currentUser = user
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
    
    func createUser(_ username: String, id: String, completion: @escaping (Error?) -> Void) {
        ref.collection("users").document(id).setData([
            "username" : username.lowercased(),
            "id" : id
        ]) { error in
            completion(error)
        }
    }
}
