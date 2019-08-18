//
//  Cast.swift
//  Example
//
//  Created by Stefano Mondino on 18/08/2019.
//  Copyright © 2019 Stefano Mondino. All rights reserved.
//

import Foundation

struct Cast: Codable {
    
    struct Character: Codable {
        let image: TVMazeImage?
        let name: String?
        let id: Int
        var poster: Image? {
            guard let url = image?.medium else { return nil }
            return Image(url: url)
        }
    }
    struct Person: Codable {
        let image: TVMazeImage?
        let name: String?
        let id: Int
        var poster: Image? {
            guard let url = image?.medium else { return nil }
            return Image(url: url)
        }
    }
    
    let character: Character
    let person: Person
    
    static func cast(from show: Show, completion: @escaping ([Cast]) -> ()) -> URLSessionDataTask {
        let url = URL(string: "http://api.tvmaze.com/shows/\(show.id)/cast")!
        return URLSession.shared.dataTask(with: url) { (data, _, _) in
            if let data = data,
                let cast = try? JSONDecoder().decode([Cast].self, from: data) {
                completion(cast)
            } else {
                completion([])
            }
        }
    }
}
