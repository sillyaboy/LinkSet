//
//  BookmarkListView.swift
//  LinkSet
//
//  Created by sillyaboy on 11/29/25.
//

import SwiftUI
import SwiftData

struct BookmarkListView: View {
    @Bindable var group: BookmarkGroup
    @Environment(\.modelContext) private var modelContext
    
    // UI 状态
    @State private var showAddLinkSheet = false
    @State private var newUrlString = ""

    var body: some View {
        VStack(spacing: 0) {
            if group.bookmarks.isEmpty {
                ContentUnavailableView("暂无链接", systemImage: "link", description: Text("点击右上角的 + 添加新链接"))
            } else {
                List {
                    // 按创建时间倒序排列
                    ForEach(group.bookmarks.sorted(by: { $0.createdAt > $1.createdAt })) { bookmark in
                        BookmarkRowView(bookmark: bookmark)
                            .listRowSeparator(.hidden) // 隐藏分割线，因为我们有卡片背景
                            .listRowInsets(EdgeInsets(top: 4, leading: 10, bottom: 4, trailing: 10))
                    }
                    .onDelete(perform: deleteBookmarks)
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle(group.name)
        .toolbar {
            // 工具栏：一键打开 & 添加
            ToolbarItemGroup(placement: .primaryAction) {
                if !group.bookmarks.isEmpty {
                    Button(action: openAllLinks) {
                        Label("打开全部", systemImage: "square.and.arrow.up.on.square")
                    }
                    .help("一键打开该组所有链接")
                }
                
                Button(action: { showAddLinkSheet = true }) {
                    Label("添加链接", systemImage: "plus")
                }
            }
        }
        // 添加链接的弹窗
        .sheet(isPresented: $showAddLinkSheet) {
            VStack(spacing: 20) {
                Text("添加新链接").font(.headline)
                
                TextField("例如: https://www.apple.com", text: $newUrlString)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 300)
                    .onSubmit {
                        addLink()
                    }
                
                HStack {
                    Button("取消") { showAddLinkSheet = false }
                        .keyboardShortcut(.escape, modifiers: [])
                    
                    Button("添加") {
                        addLink()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(newUrlString.isEmpty)
                    .keyboardShortcut(.defaultAction)
                }
                
            }
            .padding()
            .frame(width: 350, height: 150)
        }
    }
    
    // MARK: - Actions
    
    private func openAllLinks() {
        for bookmark in group.bookmarks {
            if let url = bookmark.url {
                NSWorkspace.shared.open(url)
            }
        }
    }

    private func addLink() {
        guard !newUrlString.isEmpty else { return }
        
        // 自动补全 https
        var finalUrlString = newUrlString
        if !finalUrlString.lowercased().hasPrefix("http") {
            finalUrlString = "https://" + finalUrlString
        }
        
        // 1. 立即添加到 UI (使用 URL 作为临时标题)
        let newBookmark = BookmarkItem(urlString: finalUrlString, group: group)
        newBookmark.title = finalUrlString // 临时标题
        newBookmark.summary = "正在获取信息..."
        modelContext.insert(newBookmark)
        
        // 2. 立即关闭弹窗并重置输入
        showAddLinkSheet = false
        newUrlString = ""
        
        // 3. 后台异步抓取元数据并更新
        Task {
            // 调用工具类抓取数据
            let (title, summary, iconData) = await MetadataFetcher.fetchMetadata(for: finalUrlString)
            
            // 回到主线程更新数据
            await MainActor.run {
                // 只有当数据有效时才更新，避免覆盖用户可能的手动修改（如果未来支持的话）
                if let title = title {
                    newBookmark.title = title
                }
                if let summary = summary {
                    newBookmark.summary = summary
                }
                if let iconData = iconData {
                    newBookmark.iconData = iconData
                }
            }
        }
    }

    private func deleteBookmarks(offsets: IndexSet) {
        let sortedBookmarks = group.bookmarks.sorted(by: { $0.createdAt > $1.createdAt })
        for index in offsets {
            modelContext.delete(sortedBookmarks[index])
        }
    }
}
