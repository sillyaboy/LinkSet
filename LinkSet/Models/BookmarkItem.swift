//
//  BookmarkItem.swift
//  LinkSet
//
//  Created by sillyaboy on 11/29/25.
//

import Foundation
import SwiftData

@Model
final class BookmarkItem {
    var urlString: String
    var title: String?
    var summary: String?
    var iconData: Data? // 图片以二进制数据存储
    var createdAt: Date
    
    // 反向关联到分组
    var group: BookmarkGroup?
    
    init(urlString: String, group: BookmarkGroup) {
        self.urlString = urlString
        self.group = group
        self.createdAt = Date()
    }
    
    // 方便使用的计算属性
    var url: URL? {
        URL(string: urlString)
    }
}
