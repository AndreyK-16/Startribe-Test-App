//
//  RealmService.swift
//  Startribe Test App
//
//  Created by Andrey Kaldyaev on 13.01.2026.
//

import Foundation
import RealmSwift

class RealmService {
    static let shared = RealmService()
    
    private var realm: Realm {
        do {
            return try Realm()
        } catch {
            fatalError("Failed to initialize Realm: \(error)")
        }
    }
    
    private init() {}
    
    // MARK: - News Items
    func getAllNewsItems() -> Results<NewsItem> {
        return realm.objects(NewsItem.self).sorted(byKeyPath: "pubDate", ascending: false)
    }
    
    func saveNewsItems(_ items: [NewsItem]) {
        do {
            try realm.write {
                for item in items {
                    // Check if item already exists
                    if let existing = realm.object(ofType: NewsItem.self, forPrimaryKey: item.id) {
                        // Update existing item but preserve isRead status
                        let wasRead = existing.isRead
                        item.isRead = wasRead
                    }
                    realm.add(item, update: .modified)
                }
            }
        } catch {
            print("Error saving news items: \(error)")
        }
    }
    
    func markAsRead(id: String) {
        do {
            try realm.write {
                if let obj = realm.object(ofType: NewsItem.self, forPrimaryKey: id), !obj.isInvalidated {
                    obj.isRead = true
                }
            }
        } catch {
            print("Error marking item as read: \(error)")
        }
    }

    func markAsRead(_ item: NewsItem) {
        if item.isInvalidated { return }
        markAsRead(id: item.id)
    }
    
    func deleteAllNews() {
        do {
            try realm.write {
                realm.delete(realm.objects(NewsItem.self))
            }
        } catch {
            print("Error deleting all news: \(error)")
        }
    }
    
    // MARK: - Settings
    
    func getSettings() -> AppSettings {
        if let settings = realm.object(ofType: AppSettings.self, forPrimaryKey: "settings") {
            return settings
        } else {
            let settings = AppSettings()
            settings.enabledSources = NewsSource.defaultSources
            do {
                try realm.write {
                    realm.add(settings)
                }
            } catch {
                print("Error creating settings: \(error)")
            }
            return settings
        }
    }
    
    func saveSettings(_ settings: AppSettings) {
        do {
            try realm.write {
                realm.add(settings, update: .modified)
            }
        } catch {
            print("Error saving settings: \(error)")
        }
    }
    
    func updateRefreshInterval(_ minutes: Int) {
        let settings = getSettings()
        do {
            try realm.write {
                settings.refreshIntervalMinutes = minutes
            }
        } catch {
            print("Error updating refresh interval: \(error)")
        }
    }
    
    func updateEnabledSources(_ sources: [NewsSource]) {
        let settings = getSettings()
        do {
            try realm.write {
                settings.enabledSources = sources
            }
        } catch {
            print("Error updating enabled sources: \(error)")
        }
    }
}
