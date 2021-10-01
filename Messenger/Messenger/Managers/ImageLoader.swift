//
//  ImageLoader.swift
//  Pangea
//
//  Created by Usman Turkaev on 18.07.2021.
//

import UIKit
import Reachability

var reachability: Reachability {
    return Reachability()
}

final class ImageLoader {
    
    static var shared = ImageLoader()
    
    private init() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.reachabilityChanged), name: NSNotification.Name.reachabilityChanged, object: nil)
        do {
            try reachability.startNotifier()
        }
        catch(let error) {
            print("Error occured while starting reachability notifications : \(error.localizedDescription)")
        }
    }

    @objc
    func reachabilityChanged() {
    }
    
    
    var images: [String : UIImage] = [:]
    
    var tasks: [String : URLSessionDataTask] = [:]
    
    var listeners: [String : [(UIImage) -> Void]] = [:]
    
    var waitingForInternet: [() -> Void] = []

    func downloadImageFromURL(_ imageURL: String, size: CGFloat?  = nil, completion: @escaping (UIImage) -> Void) {
        
        if let task = tasks[imageURL] {
            if let image = images[imageURL] {
                completion(image)
            } else {
                listeners[imageURL]?.append(completion)
            }
            return
        }
        
        listeners[imageURL] = [completion]
        
        runTask(imageURL: imageURL, size: size)
    }
    
    func runTask(imageURL: String, size: CGFloat? = nil) {
        
        guard let url = URL(string: imageURL) else {
            return
        }
        
        let dataTask = URLSession.shared.dataTask(with: url, completionHandler: { (data, respones, error) in
            guard error == nil,
                  let data = data else {
                print(error?.localizedDescription ?? "")
                self.waitingForInternet.append {
                    self.runTask(imageURL: imageURL, size: size)
                }
                return
            }
            
            guard var image = UIImage(data: data) else { return }
            
            if let size = size {
                image = image.aspectFittedToHeight(size)
            }
            
            self.images[imageURL] = image
            
            if let completions = self.listeners[imageURL] {
                for completion in completions {
                    completion(image)
                }
            }
        })
        dataTask.resume()
        tasks[imageURL] = dataTask
    }
}
