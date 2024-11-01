//
//  FlickrSearchViewModel.swift
//  ImageSearch
//
//  Created by Steve Lederer on 11/1/24.
//

import Foundation

@MainActor
class FlickrSearchViewModel: ObservableObject {
    @Published var query = "" {
        didSet {
            debounceSearch()
        }
    }
    @Published var searchResults: [FlickrPhoto] = []
    @Published var errorMessage: String?
    @Published var isLoading = false

    private var apiService: FlickrAPIService
    private var debounceTimer: DispatchWorkItem?
    
    init(apiService: FlickrAPIService = FlickrAPIService.shared) {
        self.apiService = apiService
    }

    private func debounceSearch() {
        // Cancel any existing debounce task
        debounceTimer?.cancel()

        // Create a new debounce task with a 0.5-second delay
        let task = DispatchWorkItem { [weak self] in
            Task {
                await self?.searchPhotos()
            }
        }

        // Assign and schedule the new task
        debounceTimer = task
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: task)
    }

    func searchPhotos() async {
        guard !query.isEmpty else {
            searchResults = []
            return
        }

        isLoading = true

        do {
            let fetchedPhotos = try await apiService.searchPhotos(
                query: query)
            if fetchedPhotos.allSatisfy({
                !$0.media.urlString.isEmpty && !$0.title.isEmpty
                    && !$0.author.isEmpty && !$0.publishedDate.isEmpty
                    && !$0.description.isEmpty
            }) {
                self.searchResults = fetchedPhotos
            } else {
                throw URLError(.badServerResponse)
            }
        } catch {
            errorMessage = error.localizedDescription
            print("Error fetching photos: \(error.localizedDescription)")
        }

        isLoading = false
    }
}
