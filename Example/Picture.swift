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
    var ratio: CGFloat
    var id: Int
    
    init(id: Int, ratio: CGFloat = 4.0/3.0) {
        self.id = id
        self.ratio = ratio
    }
    var url: URL {
        let width = 1000
        let height = Int(round(CGFloat(width) / ratio))
        return URL(string:"http://lorempixel.com/\(width)/\(height)/food/\(id % 11)")!
    }
    
    func download(_ completion: @escaping (UIImage) -> ()) -> URLSessionTask {
        print (url)
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            DispatchQueue.main.async {
                if let data = data, let image = UIImage(data: data) {
                    completion(image)
                } else {
                    completion(UIImage())
                }
            }
        }
        task.resume()
        return task
    }
}
