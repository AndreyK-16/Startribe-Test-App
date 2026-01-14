//
//  TabBarView.swift
//  Startribe Test App
//
//  Created by Andrey Kaldyaev on 13.01.2026.
//

import SwiftUI

struct TabBarView: View {
    var body: some View {
        TabView {
            NewsFeedView()
                .tabItem {
                    Label("Новости", systemImage: "newspaper")
                }
            
            SettingsView()
                .tabItem {
                    Label("Настройки", systemImage: "gearshape")
                }
        }
    }
}
