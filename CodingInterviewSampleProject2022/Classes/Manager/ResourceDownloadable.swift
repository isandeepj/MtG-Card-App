//
//  ResourceDownloadable.swift
//  CodingInterviewSampleProject2022
//
//  Created by Sandeep on 07/03/24.
//

import Foundation
import UIKit

protocol DownloadableFile {
    var id: String { get }
    var prefix: String { get }

    func fileName() -> String?
    func filePath() -> URL?
    func fileExists() -> Bool
    func fileRemoteURL() -> URL?
    func imageAtFile() -> UIImage?
}

extension DownloadableFile {
    func filePath() -> URL? {
        guard let name = self.fileName() else { return nil }
        return cacheDirectoryURL.appendingPathComponent(name)
    }

    func fileName() -> String? {
        return "\(self.id)\(self.prefix)"
    }

    func fileExists() -> Bool {
        guard let url = filePath() else { return false }
        if FileManager.default.fileExists(atPath: url.path) {
            CacheManager.shared.mainCache.updateAccessDate(url) // Update last accessed date for LRU cache
            return true
        }
        return false
    }

    func imageAtFile() -> UIImage? {
        guard let url = filePath(), let data = try? Data(contentsOf: url) else { return nil }
        return UIImage(data: data)
    }

    func deleteLocalFile() {
        guard let url = filePath() else { return }
        try? FileManager.default.removeItem(at: url)
    }
}
struct ResourceDownloadable: DownloadableFile, Hashable, Equatable {
    enum Identifier {
        /// The underlying value type of source identifier.
        public typealias Value = UInt
        static var current: Value = 0
        static func next() -> Value {
            current += 1
            return current
        }
    }
    var id: String
    var prefix: String
    let downloadURL: URL

    init(downloadURL: URL, cacheKey: String? = nil) {
        self.id = ""
        self.downloadURL = downloadURL
        self.prefix = cacheKey ?? downloadURL.absoluteString
    }
    init?(file: DownloadableFile) {
        guard let url = file.fileRemoteURL() else {
            return nil
        }
        self.id = file.id
        self.downloadURL = url
        self.prefix = file.prefix
    }
    func hash(into hasher: inout Hasher) {
        if !id.isEmpty { hasher.combine(id) }
        if !prefix.isEmpty { hasher.combine(prefix) }
        hasher.combine(downloadURL)
    }
    static func == (lhs: ResourceDownloadable, rhs: ResourceDownloadable) -> Bool {
        return lhs.id == rhs.id && lhs.prefix == rhs.prefix && lhs.downloadURL == rhs.downloadURL
    }
    func fileRemoteURL() -> URL? {
        return downloadURL
    }

}

struct ImageDownloadResult: Hashable {
    let image: UIImage?
    let url: URL
    var size: CGSize? {
        return image?.size
    }
    init(downloadURL: URL, image: UIImage?) {
        self.url = downloadURL
        self.image = image
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(url)
    }
}

