//
//  FlickrAPIService.swift
//  ImageSearch
//
//  Created by Steve Lederer on 11/1/24.
//

import Foundation

class FlickrAPIService {
    static let shared = FlickrAPIService()
    
    func searchPhotos(query: String) async throws -> [FlickrPhoto] {
        let formattedQuery = query.replacingOccurrences(of: " ", with: ",")
        let urlString =
            "https://api.flickr.com/services/feeds/photos_public.gne?format=json&nojsoncallback=1&tags=\(formattedQuery)"

        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }

        let (data, _) = try await URLSession.shared.data(from: url)
        let searchResult = try JSONDecoder().decode(
            FlickrSearchResult.self, from: data)

        return searchResult.photos
    }
}

struct FlickrSearchResult: Codable {
    let photos: [FlickrPhoto]

    enum CodingKeys: String, CodingKey {
        case photos = "items"
    }
}
