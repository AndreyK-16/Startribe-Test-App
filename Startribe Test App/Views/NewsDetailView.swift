//
//  NewsDetailView.swift
//  Startribe Test App
//
//  Created by Andrey Kaldyaev on 14.01.2026.
//

import SwiftUI

struct NewsDetailView: View {
    let item: NewsItem
    @ObservedObject var viewModel: NewsFeedViewModel
    @State private var image: UIImage?
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(maxHeight: 300)
                        .clipped()
                } else if let imageURL = item.imageURL {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 200)
                        .overlay(ProgressView())
                        .onAppear {
                            loadImage(from: imageURL)
                        }
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    Text(item.title)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    HStack {
                        Text(item.sourceName)
                            .font(.subheadline)
                            .foregroundColor(.blue)
                        
                        Spacer()
                        
                        Text(formatDate(item.pubDate))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Divider()
                    
                    Text(item.newsDescription)
                        .font(.body)
                        .foregroundColor(.primary)
                    
                    if !item.link.isEmpty {
                        Link("Читать полностью", destination: URL(string: item.link)!)
                            .font(.headline)
                            .foregroundColor(.blue)
                            .padding(.top, 8)
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Новость")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.markAsRead(id: item.id)
        }
    }
    
    private func loadImage(from urlString: String) {
        Task {
            let loadedImage = await ImageCache.shared.getImage(from: urlString)
            await MainActor.run {
                self.image = loadedImage
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: date)
    }
}
