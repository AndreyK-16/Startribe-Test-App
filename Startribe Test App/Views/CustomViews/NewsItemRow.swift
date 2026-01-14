//
//  NewsItemRow.swift
//  Startribe Test App
//
//  Created by Andrey Kaldyaev on 14.01.2026.
//

import SwiftUI

struct NewsItemRow: View {
    let item: NewsItem
    let isExpanded: Bool
    @State private var image: UIImage?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 200)
                    .clipped()
                    .cornerRadius(8)
            } else if let imageURL = item.imageURL {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 200)
                    .overlay(ProgressView())
                    .cornerRadius(8)
                    .onAppear {
                        loadImage(from: imageURL)
                    }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.headline)
                    .foregroundColor(item.isRead ? .gray : .primary)
                    .lineLimit(isExpanded ? nil : 2)
                
                if isExpanded {
                    Text(item.newsDescription)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(3)
                }
                
                HStack {
                    Text(item.sourceName)
                        .font(.caption)
                        .foregroundColor(.blue)
                    
                    Spacer()
                    
                    Text(formatDate(item.pubDate))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 4)
        }
        .padding(.vertical, 8)
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
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}


#Preview {
    let newsItem = NewsItem(id: "1",
                            title: "Новый российский препарат для лечения рака поступил в больницы",
                            description: "Российский радиофармацевтический лекарственный препарат &laquo;Ракурс 223Ra&raquo; прошел государственную регистрацию, разрешен к использованию в клинической онкологии, первая партия уже поступила в медучреждения.",
                            link: "https://www.rbc.ru/rbcfreenews/69676ff29a7947ee2ac0810a",
                            imageURL: "https://s0.rbk.ru/v6_top_pics/media/img/7/29/347683887541297.jpeg",
                            pubDate: Date(),
                            sourceName: "vedomosti")
    
    NewsItemRow(item: newsItem, isExpanded: true)
}
