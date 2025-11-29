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
    @State private var isFetching = false

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
                        Task { await addLink() }
                    }
                
                HStack {
                    Button("取消") { showAddLinkSheet = false }
                        .keyboardShortcut(.escape, modifiers: [])
                    
                    Button("添加") {
                        Task { await addLink() }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(newUrlString.isEmpty || isFetching)
                    .keyboardShortcut(.defaultAction)
                }
                
                if isFetching {
                    HStack {
                        ProgressView().controlSize(.small)
                        Text("正在抓取标题和图标...").font(.caption).foregroundStyle(.secondary)
                    }
                }
            }
            .padding()
            .frame(width: 350, height: 200)
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

    private func addLink() async {
        guard !newUrlString.isEmpty else { return }
        
        // 自动补全 https
        if !newUrlString.lowercased().hasPrefix("http") {
            newUrlString = "https://" + newUrlString
        }
        
        withAnimation { isFetching = true }
        
        // 调用工具类抓取数据
        let (title, summary, iconData) = await MetadataFetcher.fetchMetadata(for: newUrlString)
        
        // 回到主线程更新数据
        await MainActor.run {
            let newBookmark = BookmarkItem(urlString: newUrlString, group: group)
            newBookmark.title = title ?? "无标题"
            newBookmark.summary = summary ?? "无简介"
            newBookmark.iconData = iconData
            
            modelContext.insert(newBookmark)
            
            // 重置状态
            isFetching = false
            showAddLinkSheet = false
            newUrlString = ""
        }
    }

    private func deleteBookmarks(offsets: IndexSet) {
        let sortedBookmarks = group.bookmarks.sorted(by: { $0.createdAt > $1.createdAt })
        for index in offsets {
            modelContext.delete(sortedBookmarks[index])
        }
    }
}
