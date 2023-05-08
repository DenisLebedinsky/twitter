//
//  Tweet.swift
//  twitter
//
//  Created by Denis Lebedinsky on 09.05.23.
//

import Foundation

struct Tweet: Codable {
    var id = UUID().uuidString
    let author: TwitterUser
    let tweetContent: String
    let likesCount: Int
    let likers: [String]
    let isReply: Bool
    let parentReferences: String?
}
