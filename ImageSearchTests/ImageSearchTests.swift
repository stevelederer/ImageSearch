//
//  ImageSearchTests.swift
//  ImageSearchTests
//
//  Created by Steve Lederer on 11/1/24.
//

import XCTest

@testable import ImageSearch

@MainActor
final class ImageSearchTests: XCTestCase {
    var viewModel: FlickrSearchViewModel!
    var mockService: MockFlickrAPIService!

    override func setUp() async throws {
        try await super.setUp()
        mockService = MockFlickrAPIService()
        viewModel = FlickrSearchViewModel(apiService: mockService)
    }

    override func tearDown() async throws {
        viewModel = nil
        mockService = nil
        try await super.tearDown()
    }

    func testSearchPhotos_SuccessfulFetch() async {
        // Given
        let mockResults = [
            FlickrPhoto(
                title: "Tree porcupine Faunapark 3L0A0757",
                media: Media(
                    urlString:
                        "https://live.staticflickr.com/65535/54094151380_4bb3496afa_m.jpg"
                ),
                description:
                    " <p><a href=\"https://www.flickr.com/people/jakok/\">j.a.kok</a> posted a photo:</p> <p><a href=\"https://www.flickr.com/photos/jakok/54094151380/\" title=\"Tree porcupine Faunapark 3L0A0757\"><img src=\"https://live.staticflickr.com/65535/54094151380_4bb3496afa_m.jpg\" width=\"240\" height=\"198\" alt=\"Tree porcupine Faunapark 3L0A0757\" /></a></p> ",
                publishedDate: "2024-10-26T01:21:33Z",
                author: "nobody@flickr.com (\"j.a.kok\")"),
            FlickrPhoto(
                title: "North American Porcupine",
                media: Media(
                    urlString:
                        "https://live.staticflickr.com/65535/54093478871_3472926316_m.jpg"
                ),
                description:
                    " <p><a href=\"https://www.flickr.com/people/136120888@N05/\">Scotty7949e</a> posted a photo:</p> <p><a href=\"https://www.flickr.com/photos/136120888@N05/54093478871/\" title=\"North American Porcupine\"><img src=\"https://live.staticflickr.com/65535/54093478871_3472926316_m.jpg\" width=\"240\" height=\"160\" alt=\"North American Porcupine\" /></a></p> <p>Northern Wisconsin</p> ",
                publishedDate: "2024-10-25T22:28:41Z",
                author: "nobody@flickr.com (\"Scotty7949e\")"),
            FlickrPhoto(
                title: "06 African Crested Porcupine",
                media: Media(
                    urlString:
                        "https://live.staticflickr.com/65535/54077728957_d407c00486_m.jpg"
                ),
                description:
                    " <p><a href=\"https://www.flickr.com/people/megatti/\">megatti</a> posted a photo:</p> <p><a href=\"https://www.flickr.com/photos/megatti/54077728957/\" title=\"06 African Crested Porcupine\"><img src=\"https://live.staticflickr.com/65535/54077728957_d407c00486_m.jpg\" width=\"240\" height=\"160\" alt=\"06 African Crested Porcupine\" /></a></p> <p>African crested porcupine</p> ",
                publishedDate: "2024-10-19T21:05:07Z",
                author: "nobody@flickr.com (\"megatti\")"),
        ]
        mockService.mockSearchResults = mockResults

        // When
        viewModel.query = "porcupine"

        // Wait to allow debounce delay
        try? await Task.sleep(nanoseconds: 600_000_000)  // 0.6 seconds

        // Then
        XCTAssertTrue(
            mockService.searchPhotosCalled,
            "searchPhotos should be called on the service")
        XCTAssertEqual(
            viewModel.searchResults.count, mockResults.count,
            "photos should contain the expected count of mock photos after search"
        )
        XCTAssertEqual(
            viewModel.searchResults.first?.title,
            "Tree porcupine Faunapark 3L0A0757",
            "first photo should have the expected title")
        XCTAssertEqual(
            viewModel.searchResults.first?.publishedDate,
            "2024-10-26T01:21:33Z",
            "first photo should have the expected publishedDate")
        XCTAssertNil(
            viewModel.errorMessage,
            "errorMessage should be nil when search is successful")
    }

    func testSearchPhotos_ErrorHandling() async {
        // Given
        mockService.shouldThrowError = true

        // When
        viewModel.query = "porcupine"

        // Wait to allow debounce delay
        try? await Task.sleep(nanoseconds: 600_000_000)  // 0.6 seconds

        // Then
        XCTAssertTrue(
            viewModel.searchResults.isEmpty,
            "photos should be empty when an error occurs")
        XCTAssertEqual(
            viewModel.errorMessage, "Mock Error",
            "errorMessage should be set when an error occurs")
    }

    func testSearchPhotos_WithEmptyQuery_ClearsPhotos() async {
        // Given
        mockService.mockSearchResults = [
            FlickrPhoto(
                title: "Test Photo", media: Media(urlString: ""),
                description: "", publishedDate: "", author: "")
        ]

        // When
        viewModel.query = ""

        // Then
        XCTAssertTrue(
            viewModel.searchResults.isEmpty,
            "photos should be empty when query is empty")
        XCTAssertNil(
            viewModel.errorMessage,
            "errorMessage should be nil when query is empty")
    }

    func testSearchPhotos_TogglesIsLoadingState() async {
        // Given
        mockService.mockSearchResults = [
            FlickrPhoto(
                title: "Test Photo", media: Media(urlString: ""),
                description: "", publishedDate: "", author: "")
        ]
        viewModel.query = "test query"

        // When
        let initialLoadingState = viewModel.isLoading
        try? await Task.sleep(nanoseconds: 600_000_000)  // 0.6 seconds

        // Then
        XCTAssertTrue(
            initialLoadingState == false, "isLoading should initially be false")
        XCTAssertTrue(
            viewModel.isLoading == false,
            "isLoading should be false after loading")
    }

}
