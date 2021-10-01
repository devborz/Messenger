//
//  Message.swift
//  Pangea
//
//  Created by Усман Туркаев on 20.08.2021.
//

import UIKit
import FirebaseDatabase

func formatMessageTime(_ messageDate: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "HH:mm"
    return dateFormatter.string(from: messageDate)
}

enum MessageContent {
    case text(text: String)
    case image(image: UIImage)
    case location(location: Location)
}

enum MessageAttachment: Hashable {
    case empty
    case location(location: Location)
    case image(url: String)
}

enum MessageType: String {
    case text, image, location
}

enum MessageKind: String {
    case incoming, outgoing
}

struct Message: Hashable {
    
    var id: String
    var type: MessageType
    var text: String
    var created: Date
    var updated: Date
    var senderID: String
    var attachment: MessageAttachment
    
    var dictionary: [String: Any] {
        return [
            "id": id,
            "text": text,
            "senderID": senderID,
            "created": created,
            "updated": updated
        ]
    }
    
    var placeholder: String {
        switch type {
        case .text:
            return text
        case .image:
            return NSLocalizedString("Sent an image", comment: "")
        case .location:
            return NSLocalizedString("Sent a location", comment: "")
        }
    }
}

extension Message {
    init?(dictionary: [String: Any]) {
        guard let id = dictionary["id"] as? String,
                let typeString = dictionary["type"] as? String,
                let createTimestamp = dictionary["created"] as? TimeInterval,
                let updateTimestamp = dictionary["updated"] as? TimeInterval,
                let senderID = dictionary["senderID"] as? String
                else { return nil }
        
        guard let type = MessageType.init(rawValue: typeString) else { return nil }
        switch type {
        case .text:
            guard let text = dictionary["text"] as? String else { return nil }
            self.init(id: id, type: type, text: text, created: Date(timeIntervalSince1970: createTimestamp / 1000), updated: Date(timeIntervalSince1970: updateTimestamp / 1000), senderID: senderID, attachment: .empty)
        case .image:
            guard let url = dictionary["imageURL"] as? String else { return nil }
            self.init(id: id, type: type, text: "", created: Date(timeIntervalSince1970: createTimestamp / 1000), updated: Date(timeIntervalSince1970: updateTimestamp / 1000), senderID: senderID, attachment: .image(url: url))
        case .location:
            guard let locationDict = dictionary["location"] as? [String : Any] else { return nil }
            guard let longitude = locationDict["longitude"] as? String,
                  let latitude = locationDict["latitude"] as? String else { return nil }
            let location = Location(name: "", latitude: latitude, longitude: longitude)
            self.init(id: id, type: type, text: "", created: Date(timeIntervalSince1970: createTimestamp / 1000), updated: Date(timeIntervalSince1970: updateTimestamp / 1000), senderID: senderID, attachment: .location(location: location))
        }
    }
}

extension Message {
    
    static func == (lhs: Message, rhs: Message) -> Bool {
        return lhs.id == rhs.id
    }
    
    static func != (lhs: Message, rhs: Message) -> Bool {
        return lhs.id != rhs.id
    }
    
}
