//
//  NewsItem.swift
//  Startribe Test App
//
//  Created by Andrey Kaldyaev on 13.01.2026.
//

import Foundation
import RealmSwift

class NewsItem: Object, Identifiable {
    @Persisted(primaryKey: true) var id: String = ""
    @Persisted var title: String = ""
    @Persisted var newsDescription: String = ""
    @Persisted var link: String = ""
    @Persisted var imageURL: String?
    @Persisted var pubDate: Date = Date()
    @Persisted var sourceName: String = ""
    @Persisted var isRead: Bool = false
    
    convenience init(
        id: String,
        title: String,
        description: String,
        link: String,
        imageURL: String?,
        pubDate: Date,
        sourceName: String
    ) {
        self.init()
        self.id = id
        self.title = title
        self.newsDescription = description
        self.link = link
        self.imageURL = imageURL
        self.pubDate = pubDate
        self.sourceName = sourceName
    }
}
