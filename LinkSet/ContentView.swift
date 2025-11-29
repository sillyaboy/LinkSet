//
//  ContentView.swift
//  LinkSet
//
//  Created by sillyaboy on 11/29/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    // Use explicit SortDescriptor to avoid ambiguity
    @Query(sort: [SortDescriptor(\BookmarkGroup.createdAt, order: .forward)]) private var groups: [BookmarkGroup]
        
    @State private var selectedGroup: BookmarkGroup?
    @State private var showAddGroupAlert = false
    @State private var newGroupName = ""

    var body: some View {
        NavigationSplitView {
            // --- 侧边栏 ---
            List(selection: $selectedGroup) {
                Section("我的书签") {
                    ForEach(groups) { group in
                        NavigationLink(value: group) {
                            HStack {
                                Image(systemName: "folder")
                                Text(group.name)
                            }
                        }
                    }
                    .onDelete(perform: deleteGroups)
                }
            }
            .navigationSplitViewColumnWidth(min: 200, ideal: 200)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showAddGroupAlert = true }) {
                        Label("新建分组", systemImage: "folder.badge.plus")
                    }
                    .help("创建一个新的书签分组")
                }
            }
            .alert("新建分组", isPresented: $showAddGroupAlert) {
                TextField("分组名称", text: $newGroupName)
                Button("取消", role: .cancel) { newGroupName = "" }
                Button("创建") {
                    addGroup()
                    newGroupName = ""
                }
            }
            
        } detail: {
            // --- 详情区 ---
            if let group = selectedGroup {
                BookmarkListView(group: group)
                    .id(group.id) // 强制刷新视图以避免数据绑定不同步
            } else {
                VStack(spacing: 15) {
                    Image(systemName: "macwindow.on.rectangle")
                        .font(.system(size: 60))
                        .foregroundStyle(.secondary.opacity(0.3))
                    Text("欢迎使用 LinkSet")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                    Text("请在侧边栏选择或创建一个分组")
                        .foregroundStyle(.tertiary)
                }
            }
        }
    }

    private func addGroup() {
        guard !newGroupName.isEmpty else { return }
        let group = BookmarkGroup(name: newGroupName)
        modelContext.insert(group)
        selectedGroup = group
    }

    private func deleteGroups(offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(groups[index])
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: BookmarkGroup.self, inMemory: true)
}
