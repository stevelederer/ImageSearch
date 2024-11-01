//
//  MockFlickrAPIService.swift
//  ImageSearch
//
//  Created by Steve Lederer on 11/1/24.
//

import Foundation

class MockFlickrAPIService: FlickrAPIService {
    var mockSearchResults: [FlickrPhoto] = []
    var shouldThrowError = false
    var searchPhotosCalled = false

    override func searchPhotos(query: String) async throws -> [FlickrPhoto] {
        if shouldThrowError {
            throw NSError(
                domain: "TestError", code: 1,
                userInfo: [NSLocalizedDescriptionKey: "Mock Error"])
        }
        searchPhotosCalled = true
        return mockSearchResults
    }
}
