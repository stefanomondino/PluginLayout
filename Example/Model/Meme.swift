//
//  Show.swift
//  Example
//
//  Created by Stefano Mondino on 17/08/2019.
//  Copyright © 2019 Stefano Mondino. All rights reserved.
//

import Foundation
import CoreGraphics

struct Meme: Codable {
    let id: String
    let name: String
    let url: URL
    let width: CGFloat
    let height: CGFloat
    var size: CGSize {
        .init(width: width, height: height)
    }
    static func all() -> [Meme] {
        guard let source = Bundle.main.url(forResource: "memes", withExtension: "json"),
            let data = try? Data(contentsOf: source),
            let memes = try? JSONDecoder().decode([Meme].self, from: data) else {
                return []
        }
        return memes
    }
}
