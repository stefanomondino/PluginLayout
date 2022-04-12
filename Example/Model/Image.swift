//
//  Image.swift
//  Example
//
//  Created by Stefano Mondino on 17/08/2019.
//  Copyright © 2019 Stefano Mondino. All rights reserved.
//

import Foundation
import UIKit

class ImageCache {
    private var cache = NSCache<NSURL, UIImage>()
    subscript(key: URL) -> UIImage? {
        get {
            return cache.object(forKey: key as NSURL)
        }
        set {
            if let image = newValue {
                cache.setObject(image, forKey: key as NSURL)
            }
            
        }
    }
}
extension URL {
    func download(_ completion: @escaping (UIImage) -> Void) -> URLSessionTask? {
        if let cached = Image.cache[self] {
            completion(cached)
            return nil
        }
        let task = URLSession.shared.dataTask(with: self) { (data, _, _) in
            DispatchQueue.main.async {
                if let data = data, let image = UIImage(data: data) {
                    Image.cache[self] = image
                    completion(image)
                } else {
                    //                    Picture.cache.removeObject(forKey: self.url as NSURL)
                    completion(UIImage())
                }
            }
        }
        task.resume()
        return task
    }
}
struct Image {
    let url: URL
    static var cache = ImageCache()
    func download(_ completion: @escaping (UIImage) -> Void) -> URLSessionTask? {
        url.download(completion)
    }
}
