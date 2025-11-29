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
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [BookmarkGroup.self, BookmarkItem.self])
    }
}
