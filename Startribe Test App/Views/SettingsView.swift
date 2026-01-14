//
//  SettingsView.swift
//  Startribe Test App
//
//  Created by Andrey Kaldyaev on 14.01.2026.
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @State private var isRefreshing = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Обновление")) {
                    Picker("Частота обновления", selection: Binding(
                        get: { viewModel.refreshIntervalMinutes },
                        set: { viewModel.updateRefreshInterval($0) }
                    )) {
                        ForEach(viewModel.refreshIntervalOptions, id: \.self) { minutes in
                            Text(formatInterval(minutes)).tag(minutes)
                        }
                    }
                    
                    Button(action: {
                        Task {
                            isRefreshing = true
                            await viewModel.refreshData()
                            isRefreshing = false
                        }
                    }) {
                        HStack {
                            Text("Обновить сейчас")
                            if isRefreshing {
                                Spacer()
                                ProgressView()
                            }
                        }
                    }
                }
                
                Section(header: Text("Источники новостей")) {
                    ForEach(Array(viewModel.enabledSources.enumerated()), id: \.element.id) { index, source in
                        Toggle(source.name, isOn: Binding(
                            get: { viewModel.enabledSources[index].isEnabled },
                            set: { _ in viewModel.toggleSource(source) }
                        ))
                    }
                }
                
                Section(header: Text("Кэш")) {
                    HStack {
                        Text("Размер кэша")
                        Spacer()
                        Text(viewModel.formatCacheSize())
                            .foregroundColor(.secondary)
                    }
                    
                    Button(action: {
                        viewModel.clearCache()
                    }) {
                        Text("Очистить кэш")
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Настройки")
            .onAppear {
                viewModel.updateCacheSize()
            }
        }
    }
    
    private func formatInterval(_ minutes: Int) -> String {
        if minutes < 60 {
            return "\(minutes) мин"
        } else {
            let hours = minutes / 60
            return "\(hours) ч"
        }
    }
}
