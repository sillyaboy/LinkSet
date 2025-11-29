//
//  MetadataFetcher.swift
//  LinkSet
//
//  Created by sillyaboy on 11/29/25.
//

import LinkPresentation
import SwiftUI
import UniformTypeIdentifiers

class MetadataFetcher {
    /// 异步抓取网址的元数据（标题、图标等）
    static func fetchMetadata(for urlString: String) async -> (title: String?, summary: String?, iconData: Data?) {
        // 尝试构建 URL，如果失败则返回空
        guard let url = URL(string: urlString) else { return (nil, nil, nil) }
        
        let provider = LPMetadataProvider()
        
        do {
            // 开始请求元数据
            let metadata = try await provider.startFetchingMetadata(for: url)
            
            let title = metadata.title
            
            // 尝试获取图标数据
            var iconData: Data? = nil
            if let iconProvider = metadata.iconProvider {
                // 请求图片类型的数据
                let data = try await iconProvider.loadItem(forTypeIdentifier: UTType.image.identifier)
                
                if let data = data as? Data {
                    iconData = data
                } else if let url = data as? URL {
                    // 如果返回的是文件路径 URL，则读取文件内容
                    iconData = try? Data(contentsOf: url)
                }
            }
            
            // 尝试获取网页描述作为 summary
            var summary: String? = nil
            
            // 1. 尝试从 URLRequest 获取 HTML 并解析 meta description
            if summary == nil {
                summary = await fetchHTMLDescription(from: url)
            }
            
            // 2. 如果还是没有，使用 Host 作为降级方案
            if summary == nil {
                summary = url.host()
            }
            
            return (title, summary, iconData)
            
        } catch {
            print("LinkSet Error: Failed to fetch metadata for \(urlString). Error: \(error.localizedDescription)")
            // 即使 LP 失败，也尝试手动获取一下
             let summary = await fetchHTMLDescription(from: url)
            return (nil, summary ?? url.host(), nil)
        }
    }
    
    private static func fetchHTMLDescription(from url: URL) async -> String? {
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let html = String(data: data, encoding: .utf8) {
                // 简单的正则匹配 <meta name="description" content="..."> 或 <meta property="og:description" content="...">
                // 注意：这只是一个简单的实现，对于复杂的 HTML 可能不准确
                
                let patterns = [
                    "<meta\\s+name=\"description\"\\s+content=\"([^\"]+)\"",
                    "<meta\\s+property=\"og:description\"\\s+content=\"([^\"]+)\""
                ]
                
                for pattern in patterns {
                    if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
                        let range = NSRange(location: 0, length: html.utf16.count)
                        if let match = regex.firstMatch(in: html, options: [], range: range) {
                            if let swiftRange = Range(match.range(at: 1), in: html) {
                                return String(html[swiftRange])
                            }
                        }
                    }
                }
            }
        } catch {
            print("Failed to fetch HTML: \(error)")
        }
        return nil
    }
}
