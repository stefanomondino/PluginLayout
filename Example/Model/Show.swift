//
//  Show.swift
//  Example
//
//  Created by Stefano Mondino on 17/08/2019.
//  Copyright © 2019 Stefano Mondino. All rights reserved.
//

import Foundation

struct TVMazeImage: Codable {
    let medium: URL?
    let original: URL?
}

struct Show: Codable {
    let id: Int
    let name: String?
    let genres: [String]?
    var genre: String? {
        return genres?.joined(separator: ", ")
    }
    var title: String { return name ?? "" }
    let image: TVMazeImage?
    var poster: Image? {
        guard let url = image?.medium else { return nil }
        return Image(url: url)
    }
    static func all() -> [Show] {
        guard let source = Bundle.main.url(forResource: "shows", withExtension: "json"),
            let data = try? Data(contentsOf: source),
            let shows = try? JSONDecoder().decode([Show].self, from: data) else {
                return []
        }
        return shows
    }
}
