//
//  NewsFeedView.swift
//  Startribe Test App
//
//  Created by Andrey Kaldyaev on 14.01.2026.
//

import SwiftUI

struct NewsFeedView: View {
    @StateObject private var viewModel = NewsFeedViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.newsItems.isEmpty && !viewModel.isLoading {
                    VStack {
                        Image(systemName: "newspaper")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("Новостей пока нет")
                            .font(.title2)
                            .foregroundColor(.gray)
                        Text("Потяните вниз для обновления")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                } else {
                    List(viewModel.newsItems) { item in
                        NavigationLink(destination: NewsDetailView(item: item, viewModel: viewModel)) {
                            NewsItemRow(item: item, isExpanded: viewModel.isExpandedView)
                        }
                    }
                    .listStyle(PlainListStyle())
                }
                
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                }
            }
            .navigationTitle("Новости")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        viewModel.toggleViewMode()
                    }) {
                        Image(systemName: viewModel.isExpandedView ? "list.bullet" : "list.bullet.rectangle")
                    }
                }
            }
            .refreshable {
                await viewModel.refresh()
            }
            .onAppear {
                Task {
                    await viewModel.refresh()
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .refreshIntervalChanged)) { _ in
                viewModel.updateRefreshInterval()
            }
        }
    }
}
