//
//  User.swift
//  Pangea
//
//  Created by  AdamRouss🐺 on 10.02.2021.
//

import UIKit
import FirebaseFirestore

struct User: Equatable, Hashable {
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.id == rhs.id
    }
    
    var id: String
    var username: String
    var email: String? = nil
    var avatarURL: String? = nil
    var c_avatarURL: String? = nil
    
    var dictionary: [String : Any?] {
        return [
            "id" : id,
            "username" : username,
            "email" : email,
            "avatarURL": avatarURL,
            "c_avatarURL": c_avatarURL,
        ]
    }
}

extension User {
    init?(dictionary: [String: Any]) {
        guard let id = dictionary["id"] as? String,
              let username = dictionary["username"] as? String else { return nil }
        let avatarURL = dictionary["avatarURL"] as? String
        let c_avatarURL = dictionary["c_avatarURL"] as? String
        let email = dictionary["email"] as? String
        self.init(id: id, username: username, email: email, avatarURL: avatarURL, c_avatarURL: c_avatarURL)
    }
}
