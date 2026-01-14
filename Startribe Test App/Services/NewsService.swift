//
//  NewsService.swift
//  Startribe Test App
//
//  Created by Andrey Kaldyaev on 13.01.2026.
//

import Foundation

class NewsService {
    static let shared = NewsService()
    private let realmService = RealmService.shared
    private let rssParser = RSSParser.shared
    
    private init() {}
    
    func fetchNews(from sources: [NewsSource]) async {
        var allNews: [NewsItem] = []
        
        await withTaskGroup(of: [NewsItem].self) { group in
            for source in sources where source.isEnabled {
                group.addTask {
                    guard let url = URL(string: source.url) else { return [] }
                    do {
                        let items = try await self.rssParser.parseRSS(
                            from: url,
                            sourceName: source.name,
                            sourceURL: source.url
                        )
                        return items
                    } catch {
                        print("Error fetching news from \(source.name): \(error)")
                        return []
                    }
                }
            }
            for await items in group {
                allNews.append(contentsOf: items)
            }
        }
        realmService.saveNewsItems(allNews)
    }
    
    func refreshNews() async {
        let settings = realmService.getSettings()
        let enabledSources = settings.enabledSources.filter { $0.isEnabled }
        await fetchNews(from: enabledSources)
    }
}
