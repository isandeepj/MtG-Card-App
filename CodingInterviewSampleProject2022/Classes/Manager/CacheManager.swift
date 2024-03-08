//
//  CacheManager.swift
//  CodingInterviewSampleProject2022
//
//  Created by Sandeep on 07/03/24.
//

import Foundation

class CacheManager {
    static let shared = CacheManager()

    let mainCache: DiskCache

    init() {
        mainCache = DiskCache(directory: cacheDirectoryURL, capacity: 600 * 1024 * 1024) // 600MB general cache
    }
}
private var cachesDirectory: NSString {
    let searchPath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)
    return searchPath[searchPath.count - 1] as NSString
}
let cacheDirectoryPath =  cachesDirectory.appendingPathComponent("app_cache")
let cacheDirectoryURL = URL(fileURLWithPath: cacheDirectoryPath)

extension FileManager {
    static func createCacheDirectories() {
        do {
            try FileManager.default.createDirectory(atPath: cacheDirectoryPath, withIntermediateDirectories: true, attributes: nil)
        } catch _ { }
    }
}
