//
//  GroupsMenuBarView.swift
//  LinkSet
//
//  Created by sillyaboy on 11/29/25.
//

import SwiftUI
import SwiftData

struct GroupsMenuBarView: View {
    @Query(sort: [SortDescriptor(\BookmarkGroup.createdAt, order: .forward)]) private var groups: [BookmarkGroup]
    
    var body: some View {
        // 原生菜单样式不需要复杂的布局容器，直接列出按钮即可
        Text("LinkSet Groups")
        
        Divider()
        
        if groups.isEmpty {
            Button("暂无分组") {}.disabled(true)
        } else {
            ForEach(groups) { group in
                Button(action: {
                    openAllLinks(in: group)
                }) {
                    // 原生菜单中，Label 会自动显示图标和文本
                    // 注意：原生菜单对自定义布局支持有限，这里使用标准 Label
                    Label("\(group.name) (\(group.bookmarks.count))", systemImage: "folder")
                }
            }
        }
        
        Divider()
        
        Button("退出 LinkSet") {
            NSApplication.shared.terminate(nil)
        }
        .keyboardShortcut("q")
    }
    
    private func openAllLinks(in group: BookmarkGroup) {
        for bookmark in group.bookmarks {
            if let url = bookmark.url {
                NSWorkspace.shared.open(url)
            }
        }
    }
}
