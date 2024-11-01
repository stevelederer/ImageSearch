//
//  ImageDetailView.swift
//  ImageSearch
//
//  Created by Steve Lederer on 11/1/24.
//

import Kingfisher
import SwiftUI

struct ImageDetailView: View {
    let flickrPhoto: FlickrPhoto
    @State private var photoDescriptionPlainText: String?

    var body: some View {
        VStack(alignment: .leading) {
            KFImage(URL(string: flickrPhoto.media.urlString))
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)

            Text(
                (flickrPhoto.author.extractAuthorName() != nil)
                    ? "Author: \(flickrPhoto.author.extractAuthorName()!)" : ""
            )
            .font(.caption)

            Text(flickrPhoto.title)
                .font(.system(.title, weight: .bold))
                .padding(.top, 10)

            if let description = photoDescriptionPlainText,
                description.isEmpty == false
            {
                Text(description)
                    .font(.body)
                    .padding(.vertical, 5)
            }

            Text(
                (formatDate(flickrPhoto.publishedDate) != nil)
                    ? "Published on \(formatDate(flickrPhoto.publishedDate)!)"
                    : ""
            )
            .font(.footnote)
            .padding(.top, 5)
            .foregroundStyle(.gray)

            Spacer()
        }
        .onAppear {
            DispatchQueue.main.async {
                photoDescriptionPlainText = flickrPhoto.description.descriptionFromHTML()
            }
        }
        .padding()
        .navigationTitle("Photo Details")
    }

    private func formatDate(_ date: String) -> String? {
        guard let date = try? Date.ISO8601FormatStyle().parse(date) else {
            return nil
        }
        return DateFormatter.localizedString(
            from: date,
            dateStyle: .long, timeStyle: .none)
    }
}

#Preview {
    let photoExample = Media(urlString: "https://live.staticflickr.com/65535/54094151380_4bb3496afa_m.jpg")
    let photo = FlickrPhoto(
        title: "Tree porcupine",
        media: photoExample,
        description: " <p><a href=\"https://www.flickr.com/people/ladybugsleaf/\">Lady-bug</a> posted a photo:</p> <p><a href=\"https://www.flickr.com/photos/ladybugsleaf/54083670003/\" title=\"Pretty in the Park\"><img src=\"https://live.staticflickr.com/65535/54083670003_174de9184e_m.jpg\" width=\"180\" height=\"240\" alt=\"Pretty in the Park\" /></a></p> <p>This is my new friend Aria. Isn't she so beautiful?</p> ",
        publishedDate: "2024-10-26T01:21:33Z",
        author: "nobody@flickr.com (\"j.a.kok\")")
    ImageDetailView(flickrPhoto: photo)
}
