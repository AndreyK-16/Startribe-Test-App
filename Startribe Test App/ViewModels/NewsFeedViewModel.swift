//
//  NewsFeedViewModel.swift
//  Startribe Test App
//
//  Created by Andrey Kaldyaev on 13.01.2026.
//

import Foundation
import RealmSwift
import Combine

@MainActor
class NewsFeedViewModel: ObservableObject {
    @Published var newsItems: [NewsItem] = []
    @Published var isExpandedView: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let realmService = RealmService.shared
    private let newsService = NewsService.shared
    private var notificationToken: NotificationToken?
    private var refreshTimer: Timer?
    
    init() {
        loadNews()
        observeRealmChanges()
        setupAutoRefresh()
    }
    
    deinit {
        notificationToken?.invalidate()
        refreshTimer?.invalidate()
    }
    
    private func loadNews() {
        let results = realmService.getAllNewsItems()
        newsItems = Array(results)
    }
    
    private func observeRealmChanges() {
        let results = realmService.getAllNewsItems()
        notificationToken = results.observe { [weak self] changes in
            Task { @MainActor in
                self?.loadNews()
            }
        }
    }
    
    private func setupAutoRefresh() {
        let settings = realmService.getSettings()
        let interval = TimeInterval(settings.refreshIntervalMinutes * 60)
        
        refreshTimer?.invalidate()
        refreshTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            Task { @MainActor in
                await self?.refresh()
            }
        }
        RunLoop.main.add(refreshTimer!, forMode: .common)
    }
    
    func refresh() async {
        isLoading = true
        errorMessage = nil
        
//        do {
            await newsService.refreshNews()
//        } catch {
//            errorMessage = "Ошибка при обновлении новостей: \(error.localizedDescription)"
//        }
        
        isLoading = false
    }
    
    func toggleViewMode() {
        isExpandedView.toggle()
    }
    
    func markAsRead(_ item: NewsItem) {
        realmService.markAsRead(id: item.id)
    }

    func markAsRead(id: String) {
        realmService.markAsRead(id: id)
    }
    
    func clearCache() {
        ImageCache.shared.clearCache()
    }
    
    func updateRefreshInterval() {
        setupAutoRefresh()
    }
}
