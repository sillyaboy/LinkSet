//
//  BookmarkGroup.swift
//  LinkSet
//
//  Created by sillyaboy on 11/29/25.
//

import Foundation
import SwiftData

@Model
final class BookmarkGroup {
    var name: String
    var createdAt: Date
    
    // 级联删除：如果删除了分组，里面的链接也会被删除
    @Relationship(deleteRule: .cascade) var bookmarks: [BookmarkItem] = []
    
    init(name: String) {
        self.name = name
        self.createdAt = Date()
    }
}
