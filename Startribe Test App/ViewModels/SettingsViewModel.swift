//
//  SettingsViewModel.swift
//  Startribe Test App
//
//  Created by Andrey Kaldyaev on 13.01.2026.
//

import Foundation
import Combine

@MainActor
class SettingsViewModel: ObservableObject {
    @Published var refreshIntervalMinutes: Int = 30
    @Published var enabledSources: [NewsSource] = []
    @Published var cacheSize: Int64 = 0
    
    private let realmService = RealmService.shared
    private let newsService = NewsService.shared
    
    let refreshIntervalOptions = [5, 10, 15, 30, 60, 120]
    
    init() {
        loadSettings()
        updateCacheSize()
    }
    
    private func loadSettings() {
        let settings = realmService.getSettings()
        refreshIntervalMinutes = settings.refreshIntervalMinutes
        enabledSources = settings.enabledSources
    }
    
    func updateRefreshInterval(_ minutes: Int) {
        refreshIntervalMinutes = minutes
        realmService.updateRefreshInterval(minutes)
        
        // Notify NewsFeedViewModel to update timer
        NotificationCenter.default.post(name: .refreshIntervalChanged, object: nil)
    }
    
    func toggleSource(_ source: NewsSource) {
        if let index = enabledSources.firstIndex(where: { $0.id == source.id }) {
            var updatedSources = enabledSources
            updatedSources[index].isEnabled.toggle()
            enabledSources = updatedSources
            realmService.updateEnabledSources(enabledSources)
        }
    }
    
    func clearCache() {
        ImageCache.shared.clearCache()
        updateCacheSize()
    }
    
    func refreshData() async {
        await newsService.refreshNews()
    }
    
    func updateCacheSize() {
        cacheSize = ImageCache.shared.getCacheSize()
    }
    
    func formatCacheSize() -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: cacheSize)
    }
}

extension Notification.Name {
    static let refreshIntervalChanged = Notification.Name("refreshIntervalChanged")
}
