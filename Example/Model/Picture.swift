//
//  Picture.swift
//  Example
//
//  Created by Stefano Mondino on 30/06/2019.
//  Copyright © 2019 Stefano Mondino. All rights reserved.
//

import Foundation
import UIKit

struct Picture {
    
    enum ContentType: String {
        case cats
        case food
        case sports
        case people
        case nature
        case show
        var ratio: CGFloat {
            switch self {
            case .show: return 9/16
            case .cats: return 4/3
            case .nature, .people: return CGFloat([16.0/9.0, 4.0/3.0, 9.0/16.0, 3.0/4.0, 21.0/9.0, 9.0/21.0].randomElement() ?? 1)
            default: return 1
            }
        }
        var max: Int {
            switch self {
            case .nature: return 6
            case .people: return 13
            case .cats: return 11
            default: return 7
            }
        }
    }
    
    var id: Int
    var type: ContentType
    var ratio: CGFloat
    
    init (show: Show) {
        self.id = show.id
        self.ratio = 9/16
        self.type = .show
        self.url = show.image?.medium ?? URL(fileURLWithPath: "")
    }
    
    init(id: Int, type: ContentType = .food) {
        self.id = id
        self.ratio = type.ratio
        self.type = type
        let width = 600
        let height = Int(round(CGFloat(width) / ratio))
        url = URL(string: "http://lorempixel.com/\(width)/\(height)/\(type.rawValue)/\(id % type.max)")!
    }
    var url: URL
    
    func download(_ completion: @escaping (UIImage) -> Void) -> URLSessionTask? {
            return Image(url: url).download(completion)
    }
//        if let cached = Picture.cache[url] {
//            completion(cached)
//            return nil
//        }
//        let task = URLSession.shared.dataTask(with: url) { (data, _, _) in
//            DispatchQueue.main.async {
//                if let data = data, let image = UIImage(data: data) {
//                    Picture.cache[self.url] = image
//                    completion(image)
//                } else {
////                    Picture.cache.removeObject(forKey: self.url as NSURL)
//                    completion(UIImage())
//                }
//            }
//        }
//        task.resume()
//        return task
//    }
}
