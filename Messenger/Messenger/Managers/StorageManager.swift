//
//  StorageManager.swift
//  Pangea
//
//  Created by Усман Туркаев on 27.02.2021.
//

import FirebaseStorage

struct MediaURLs {
    var fullSizeImagesURLs: [Int : String] = [:]
    var compressedImagesURLs: [Int : String] = [:]
}

struct AvatarURL {
    var fullSizeURL: String
    var compressedURL: String
}

final class StorageManager {
    static var shared = StorageManager()
    
    private var ref = Storage.storage().reference()
    
    private init() { }
    
    private var lastMediaURLs: MediaURLs!
    
    private var lastUploadedImages: [UIImage]!
    
    private var lastUploadedEventID: String!
    
    func deleteEventImages(_ id: String) {
        let imagesRef = ref.child("events/\(id)")
        imagesRef.listAll { (result, error) in
            guard error == nil else { return }
            for item in result.items {
                let imageRef = self.ref.child("events/\(id)/\(item.name)")
                imageRef.delete { (error) in
                }
            }
        }
    }
    
    func setCurrentUserAvatar(_ avatar: UIImage, completion: @escaping (AvatarURL) -> Void) {
        guard let id = DatabaseManager.shared.currentUserID else { return }
        let storageRef = Storage.storage().reference()
        let avatarRef = storageRef.child("avatars/\(id)/avatar.jpg")
        let c_avatarRef = storageRef.child("avatars/\(id)/avatar_compressed.jpg")
        
        var fullSizeURL: String?
        var compressedURL: String?
        
        let task_1 = avatarRef.putData(avatar.jpeg(.lowest)!, metadata: nil) { (metadata, error) in
            guard error == nil else {
                print("Load error - " + error!.localizedDescription)
                return
            }
            avatarRef.downloadURL { (url, error) in
                guard error == nil else {
                    print("URL error - " + error!.localizedDescription)
                    return
                }
                guard let downloadURL = url else { return }
                fullSizeURL = downloadURL.absoluteString
                if let compressedURL = compressedURL {
                    let avatarURL = AvatarURL(fullSizeURL: fullSizeURL!, compressedURL: compressedURL)
                    completion(avatarURL)
                }
            }
        }
        
        let task_2 = c_avatarRef.putData(avatar.aspectFittedToHeight(50).jpeg(.lowest)!, metadata: nil) { (metadata, error) in
            guard error == nil else {
                print("Load error - " + error!.localizedDescription)
                return
            }
            c_avatarRef.downloadURL { (url, error) in
                guard error == nil else {
                    print("URL error - " + error!.localizedDescription)
                    return
                }
                guard let downloadURL = url else { return }
                compressedURL = downloadURL.absoluteString
                if let fullSizeURL = fullSizeURL {
                    let avatarURL = AvatarURL(fullSizeURL: fullSizeURL, compressedURL: compressedURL!)
                    completion(avatarURL)
                }
            }
        }
    }
    
    func setEventMedia(_ images: [UIImage], with id: String, completion: @escaping (MediaURLs) -> Void) {
        let eventRef = ref.child("events/\(id)")
        lastMediaURLs = MediaURLs()
        lastUploadedImages = images
        lastUploadedEventID = id
        
        
        for i in 0..<lastUploadedImages.count {
            // Uploading full size image
            let imageRef = eventRef.child("\(i + 1).jpg")
            let task_1 = imageRef.putData(images[i].jpeg(.lowest)!, metadata: nil) { (metadata, error) in
                guard error == nil else {
                    print("Load error - " + error!.localizedDescription)
                    return
                }
                imageRef.downloadURL { (url, error) in
                    guard error == nil else {
                        print("URL error - " + error!.localizedDescription)
                        return
                    }
                    guard let downloadURL = url else { return }
                    self.lastMediaURLs.fullSizeImagesURLs[i] = downloadURL.absoluteString
                    if self.lastMediaURLs.fullSizeImagesURLs.count + self.lastMediaURLs.compressedImagesURLs.count == self.lastUploadedImages.count * 2 {
                        completion(self.lastMediaURLs)
                    }
                    
                }
            }
            
            // Uploding small size image
            let compressedImageRef = eventRef.child("\(i + 1)-compressed.jpg")
            let task_2 = compressedImageRef.putData(images[i].aspectFittedToHeight(100).jpeg(.lowest)!, metadata: nil) { (metadata, error) in
                guard error == nil else {
                    print("Load error - " + error!.localizedDescription)
                    return
                }
                compressedImageRef.downloadURL { (url, error) in
                    guard error == nil else {
                        print("URL error - " + error!.localizedDescription)
                        return
                    }
                    guard let downloadURL = url else { return }
                    self.lastMediaURLs.compressedImagesURLs[i] = downloadURL.absoluteString
                    if self.lastMediaURLs.fullSizeImagesURLs.keys.count + self.lastMediaURLs.compressedImagesURLs.keys.count == self.lastUploadedImages.count * 2 {
                        completion(self.lastMediaURLs)
                    }
                }
            }
            
            task_1.observe(.success) { snapshot in
            }
            task_2.observe(.success) { snanpshot in
            }
        }
    }
    
    func editEventMedia(_ images: [UIImage], with id: String, completion: @escaping (MediaURLs) -> Void) {
        let imagesRef = ref.child("events/\(id)")
        var count = 0
        
        lastUploadedImages = images
        lastUploadedEventID = id
        imagesRef.listAll { (result, error) in
            guard error == nil else { return }
            for item in result.items {
                let imageRef = self.ref.child("events/\(self.lastUploadedEventID!)/\(item.name)")
                imageRef.delete { (error) in
                    count += 1
                    if count == result.items.count {
                        self.setEventMedia(self.lastUploadedImages, with: self.lastUploadedEventID) { urls in
                            completion(urls)
                        }
                    }
                }
            }
        }
    }
    
    func uploadMessagePhoto(_ image: UIImage, with id: String, completion: @escaping (String) -> Void) {
        let messagesRef = ref.child("messages/\(id)")
        
        let imageRef = messagesRef.child("image.jpg")
        let task = imageRef.putData(image.jpeg(.lowest)!, metadata: nil) { (metadata, error) in
            guard error == nil else {
                print("Load error - " + error!.localizedDescription)
                return
            }
            imageRef.downloadURL { (url, error) in
                guard error == nil else {
                    print("URL error - " + error!.localizedDescription)
                    return
                }
                guard let downloadURL = url else { return }
                completion(downloadURL.absoluteString)
            }
        }
        
        task.observe(.progress) { snapshot in
            
        }
    }
}
