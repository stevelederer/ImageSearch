//
//  FlickrPhoto.swift
//  ImageSearch
//
//  Created by Steve Lederer on 11/1/24.
//

import Foundation

struct FlickrPhoto: Codable, Identifiable {
    var id = UUID()
    let title: String
    let media: Media
    let description: String
    let publishedDate: String
    let author: String

    enum CodingKeys: String, CodingKey {
        case title, media, description, author
        case publishedDate = "published"
    }
}

struct Media: Codable {
    let urlString: String

    enum CodingKeys: String, CodingKey {
        case urlString = "m"
    }
}
