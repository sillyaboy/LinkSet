//
//  LinkSetApp.swift
//  LinkSet
//
//  Created by sillyaboy on 11/29/25.
//

import SwiftUI
import SwiftData

@main
struct LinkSetApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            BookmarkGroup.self,
            BookmarkItem.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
        
        MenuBarExtra("LinkSet", systemImage: "link") {
            GroupsMenuBarView()
                .modelContainer(sharedModelContainer)
        }
        .menuBarExtraStyle(.menu) // 使用原生菜单样式
    }
}
