//
//  NewsSource.swift
//  Startribe Test App
//
//  Created by Andrey Kaldyaev on 13.01.2026.
//

import Foundation

struct NewsSource: Identifiable, Codable {
    let id: String
    let name: String
    let url: String
    var isEnabled: Bool
    
    static let defaultSources: [NewsSource] = [
        NewsSource(id: "vedomosti", name: "Ведомости", url: "https://www.vedomosti.ru/rss/news.xml", isEnabled: true),
        NewsSource(id: "rbc", name: "РБК", url: "https://rssexport.rbc.ru/rbcnews/news/30/full.rss", isEnabled: true)
    ]
}
