//
//  Settings.swift
//  Startribe Test App
//
//  Created by Andrey Kaldyaev on 13.01.2026.
//

import Foundation
import RealmSwift

class AppSettings: Object {
    @Persisted(primaryKey: true) var id: String = "settings"
    @Persisted var refreshIntervalMinutes: Int = 30
    @Persisted var enabledSourcesData: Data?
    
    var enabledSources: [NewsSource] {
        get {
            guard let data = enabledSourcesData,
                  let sources = try? JSONDecoder().decode([NewsSource].self, from: data) else {
                return NewsSource.defaultSources
            }
            return sources
        }
        set {
            enabledSourcesData = try? JSONEncoder().encode(newValue)
        }
    }
}
