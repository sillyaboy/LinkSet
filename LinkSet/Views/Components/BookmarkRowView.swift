//
//  BookmarkRowView.swift
//  LinkSet
//
//  Created by sillyaboy on 11/29/25.
//


import SwiftUI

struct BookmarkRowView: View {
    let bookmark: BookmarkItem
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            // 1. 图标显示区域
            if let data = bookmark.iconData, let nsImage = NSImage(data: data) {
                Image(nsImage: nsImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 36, height: 36)
                    .cornerRadius(6)
            } else {
                // 默认占位符
                Image(systemName: "globe")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
                    .foregroundStyle(.secondary)
                    .frame(width: 36, height: 36)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(6)
            }
            
            // 2. 文本信息区域
            VStack(alignment: .leading, spacing: 3) {
                Text(bookmark.title ?? "无标题")
                    .font(.headline)
                    .lineLimit(1)
                
                Text(bookmark.summary ?? bookmark.urlString)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            // 3. 操作按钮区域 (Hover 时显示效果更佳，这里保持常驻或简单样式)
            HStack(spacing: 10) {
                // A. 分享按钮
                if let url = bookmark.url {
                    ShareLink(item: url) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 14))
                    }
                    .buttonStyle(.plain) // 使用 plain 样式避免点击整行触发
                    .foregroundStyle(.secondary)
                    .help("分享链接")
                }
                
                // B. 打开按钮
                Button(action: {
                    if let url = bookmark.url {
                        NSWorkspace.shared.open(url)
                    }
                }) {
                    Image(systemName: "safari")
                        .font(.system(size: 14))
                }
                .buttonStyle(.plain)
                .foregroundStyle(.blue)
                .help("在浏览器中打开")
            }
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 8)
        // 给整个 Row 加个背景，使其看起来像个卡片
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(8)
    }
}
