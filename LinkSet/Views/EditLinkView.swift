//
//  EditLinkView.swift
//  LinkSet
//
//  Created by sillyaboy on 11/29/25.
//

import SwiftUI

struct EditLinkView: View {
    @Bindable var bookmark: BookmarkItem
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            Text("编辑链接").font(.headline)
            
            Form {
                TextField("标题", text: Binding(
                    get: { bookmark.title ?? "" },
                    set: { bookmark.title = $0 }
                ))
                
                TextField("网址", text: Binding(
                    get: { bookmark.urlString },
                    set: { bookmark.urlString = $0 }
                ))
                
                TextField("简介", text: Binding(
                    get: { bookmark.summary ?? "" },
                    set: { bookmark.summary = $0 }
                ))
            }
            .formStyle(.grouped)
            
            HStack {
                Button("取消") {
                    dismiss()
                }
                .keyboardShortcut(.escape, modifiers: [])
                
                Button("完成") {
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding()
        .frame(width: 400, height: 250)
    }
}
