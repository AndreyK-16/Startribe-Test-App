//
//  RSSParser.swift
//  Startribe Test App
//
//  Created by Andrey Kaldyaev on 13.01.2026.
//

import Foundation

enum RSSParserError: Error {
    case invalidData
    case parsingFailed
}

class RSSParser {
    static let shared = RSSParser()
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss ZZZ"
        return formatter
    }()
    
    private init() {}
    
    //MARK: public methods
    func parseRSS(from url: URL, sourceName: String, sourceURL: String) async throws -> [NewsItem] {
        let (data, _) = try await URLSession.shared.data(from: url)
        
        guard let xmlString = String(data: data, encoding: .utf8) else {
            throw RSSParserError.invalidData
        }
        return try parseRSSManually(xmlString: xmlString, sourceName: sourceName, sourceURL: sourceURL)
    }
    
    //MARK: private methods
    private func parseRSSManually(xmlString: String, sourceName: String, sourceURL: String) throws -> [NewsItem] {
        var items: [NewsItem] = []
        let itemPattern = "<item>(.*?)</item>"
        let regex = try NSRegularExpression(pattern: itemPattern, options: [.dotMatchesLineSeparators])
        let nsString = xmlString as NSString
        let matches = regex.matches(in: xmlString, options: [], range: NSRange(location: 0, length: nsString.length))
        
        for match in matches {
            let itemContent = nsString.substring(with: match.range(at: 1))
            
            guard let title = extractTag(content: itemContent, tag: "title"),
                  let link = extractTag(content: itemContent, tag: "link") else {
                continue
            }
            
            let description = extractTag(content: itemContent, tag: "description") ?? ""
            let pubDateString = extractTag(content: itemContent, tag: "pubDate") ?? ""
            var pubDate = Date()
            if !pubDateString.isEmpty {
                pubDate = dateFormatter.date(from: pubDateString) ?? Date()
            }
            
            var imageURL: String? = nil
            if let enclosureMatch = itemContent.range(of: "<enclosure[^>]*>", options: .regularExpression) {
                let enclosureString = String(itemContent[enclosureMatch])
                if let urlMatch = enclosureString.range(of: "url=\"([^\"]+)\"", options: .regularExpression) {
                    let urlString = String(enclosureString[urlMatch])
                    imageURL = extractURL(from: urlString)
                }
            }
            
            if imageURL == nil {
                if let mediaMatch = itemContent.range(of: "<media:content[^>]*>", options: .regularExpression) {
                    let mediaString = String(itemContent[mediaMatch])
                    if let urlMatch = mediaString.range(of: "url=\"([^\"]+)\"", options: .regularExpression) {
                        let urlString = String(mediaString[urlMatch])
                        imageURL = extractURL(from: urlString)
                    }
                }
            }
            
            if imageURL == nil {
                if let imgMatch = description.range(of: "<img[^>]+src=\"([^\"]+)\"", options: .regularExpression) {
                    let imgString = String(description[imgMatch])
                    imageURL = extractURL(from: imgString)
                }
            }
            
            let id = "\(sourceName)-\(link)".data(using: .utf8)?.base64EncodedString() ?? UUID().uuidString
            
            let newsItem = NewsItem(
                id: id,
                title: cleanHTML(title),
                description: cleanHTML(description),
                link: link,
                imageURL: imageURL,
                pubDate: pubDate,
                sourceName: sourceName
            )
            items.append(newsItem)
        }
        return items
    }
    
    private func extractTag(content: String, tag: String) -> String? {
        let pattern = "<\(tag)[^>]*>(.*?)</\(tag)>"
        let regex = try? NSRegularExpression(pattern: pattern, options: [.dotMatchesLineSeparators])
        let nsString = content as NSString
        if let match = regex?.firstMatch(in: content, options: [], range: NSRange(location: 0, length: nsString.length)) {
            if match.numberOfRanges > 1 {
                return nsString.substring(with: match.range(at: 1))
            }
        }
        return nil
    }
    
    private func extractURL(from string: String) -> String? {
        let regex = try? NSRegularExpression(pattern: "url=\"([^\"]+)\"", options: [])
        let nsString = string as NSString
        if let match = regex?.firstMatch(in: string, options: [], range: NSRange(location: 0, length: nsString.length)) {
            if match.numberOfRanges > 1 {
                return nsString.substring(with: match.range(at: 1))
            }
        }
        return nil
    }
    
    ///claen HTML - remove CDATA, tags, decoding HTML-code
    private func cleanHTML(_ html: String) -> String {
        var cleaned = html
        cleaned = cleaned.replacingOccurrences(of: "<![CDATA[", with: "")
        cleaned = cleaned.replacingOccurrences(of: "]]>", with: "")
        
        cleaned = cleaned.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
        
        cleaned = cleaned.replacingOccurrences(of: "&quot;", with: "\"")
        cleaned = cleaned.replacingOccurrences(of: "&amp;", with: "&")
        cleaned = cleaned.replacingOccurrences(of: "&lt;", with: "<")
        cleaned = cleaned.replacingOccurrences(of: "&gt;", with: ">")
        cleaned = cleaned.replacingOccurrences(of: "&apos;", with: "'")
        cleaned = cleaned.replacingOccurrences(of: "&nbsp;", with: " ")
        
        return cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
