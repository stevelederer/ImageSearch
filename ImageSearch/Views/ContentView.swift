//
//  ContentView.swift
//  ImageSearch
//
//  Created by Steve Lederer on 11/1/24.
//

import Kingfisher
import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = FlickrSearchViewModel()

    var body: some View {
        NavigationStack {
            VStack {
                if viewModel.isLoading {
                    ProgressView("Loading...").padding()
                } else {
                    ScrollView {
                        VStack {
                            LazyVGrid(columns: [
                                GridItem(.adaptive(minimum: 120))
                            ]) {
                                ForEach(viewModel.searchResults) { flickrPhoto in
                                    NavigationLink(destination: ImageDetailView(flickrPhoto: flickrPhoto)) {
                                        KFImage(URL(string: flickrPhoto.media.urlString))
                                            .resizable()
                                            .placeholder {
                                                ProgressView()
                                            }
                                            .fade(duration: 0.2)
                                            .scaledToFill()
                                            .frame(width: 120, height: 120)
                                            .clipped()
                                    }
                                }
                            }
                            if !viewModel.query.isEmpty {
                                Text("\(viewModel.searchResults.count) Results")
                                    .font(.footnote)
                                    .padding(.top, 10)
                                    .foregroundStyle(.gray)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Flickr Search")
        }
        .searchable(text: $viewModel.query, prompt: "Search for something")
        .searchPresentationToolbarBehavior(.avoidHidingContent)
    }
}

#Preview {
    ContentView()
}
