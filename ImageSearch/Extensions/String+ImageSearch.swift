//
//  String+ImageSearch.swift
//  ImageSearch
//
//  Created by Steve Lederer on 11/1/24.
//

import Foundation

extension String {
    func htmlToPlainText() -> String {
        guard let data = self.data(using: .utf8) else { return "" }

        do {
            let attributedString = try NSAttributedString(
                data: data,
                options: [
                    .documentType: NSAttributedString.DocumentType.html,
                    .characterEncoding: String.Encoding.utf8.rawValue,
                ],
                documentAttributes: nil
            )
            return attributedString.string.trimmingCharacters(
                in: .whitespacesAndNewlines)
        } catch {
            print("Failed to parse HTML: \(error)")
            return ""
        }
    }
    
    func descriptionFromHTML() -> String {
        guard let data = self.data(using: .utf8) else { return "" }

        do {
            let attributedString = try NSAttributedString(
                data: data,
                options: [
                    .documentType: NSAttributedString.DocumentType.html,
                    .characterEncoding: String.Encoding.utf8.rawValue,
                ],
                documentAttributes: nil
            )
            let plainText = attributedString.string.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "\u{fffc}", with: "\n")
            var lines = plainText.split(separator: "\n").map { $0.trimmingCharacters(in: .whitespaces) }
            lines.removeAll(where: { $0.hasSuffix("posted a photo:") })
                        
            return lines.joined()
        } catch {
            print("Failed to parse HTML: \(error)")
            return ""
        }
    }

    func extractAuthorName() -> String? {
        let dummyEmailPrefix = "nobody@flickr.com "
        guard self.hasPrefix(dummyEmailPrefix) else { return nil }

        // Get the index of the first "(" and last ")"
        guard let start = self.firstIndex(of: "("),
              let end = self.lastIndex(of: ")"),
              start < end
        else { return nil }

        // Extract the content between the parentheses and remove quotes
        let range = self.index(after: start)..<end
        let extractedAuthorName = self[range].replacingOccurrences(of: "\"", with: "")

        return extractedAuthorName
    }
    
}
