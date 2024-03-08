//
//  DiskCache.swift
//  CodingInterviewSampleProject2022
//
//  Created by Sandeep on 07/03/24.
//

import Foundation
import UIKit

class DiskCache {
   lazy var cacheQueue: DispatchQueue = {
        let queueName = "diskcache." + (directory.path as NSString).lastPathComponent
        return DispatchQueue(label: queueName, attributes: [])
    }()

    let directory: URL

   var size: UInt64 = 0
   var capacity: UInt64 = 0 {
        didSet {
            self.cacheQueue.async {
                self.controlCapacity()
            }
        }
    }

    public init(directory: URL, capacity: UInt64 = UINT64_MAX) {
        self.directory = directory
        self.capacity = capacity
        self.cacheQueue.async {
            self.calculateSize()
            self.controlCapacity()
        }
    }

   func addURL(_ url: URL) {
        guard urlInPath(url) else {
            return
        }
        cacheQueue.async {
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: url.path) {
                self.addFileURLSync(url)
            }
        }
    }

   func removeURL(_ url: URL) {
        guard urlInPath(url) else {
            return
        }
        cacheQueue.async {
            self.removeFile(atPath: url.path)
        }
    }

   func removeAllURLs(_ completion: (() -> Void)? = nil) {
        let fileManager = FileManager.default
        cacheQueue.async {
            do {
                let contents = try fileManager.contentsOfDirectory(atPath: self.directory.path)
                for pathComponent in contents {
                    let path = self.directory.appendingPathComponent(pathComponent).path
                    do {
                        try fileManager.removeItem(atPath: path)
                    } catch {
                    }
                }
                self.calculateSize()
            } catch {
            }
            if let completion = completion {
                DispatchQueue.main.async {
                    completion()
                }
            }
        }
    }

   func updateAccessDate(_ url: URL) {
        guard urlInPath(url) else {
            return
        }
        cacheQueue.async {
            self.updateDiskAccessDate(atPath: url.path)
        }
    }

    // MARK: - Private

    fileprivate func urlInPath(_ url: URL) -> Bool {
        return url.path.hasPrefix(url.path)
    }

    fileprivate func calculateSize() {
        let fileManager = FileManager.default
        size = 0

        if let contents = try? fileManager.contentsOfDirectory(atPath: directory.path) {
            for pathComponent in contents {
                let path = directory.appendingPathComponent(pathComponent).path
                if let attributes: [FileAttributeKey: Any] = try? fileManager.attributesOfItem(atPath: path), let fileSize = attributes[FileAttributeKey.size] as? UInt64 {
                    size += fileSize
                }
            }
        }
    }

    fileprivate func controlCapacity() {
        if self.size <= self.capacity { return }
        FileManager.default.enumerateContentsOfDirectory(atPath: directory.path, orderedByProperty: URLResourceKey.contentModificationDateKey.rawValue, ascending: true) { (url, _, _) in
            self.removeFile(atPath: url.path)
        }
    }

    fileprivate func subtract(size: UInt64) {
        if self.size >= size {
            self.size -= size
        } else {
            self.size = 0
        }
    }

    fileprivate func addFileURLSync(_ url: URL) {
        let fileManager = FileManager.default
        let attributes: [FileAttributeKey: Any]? = try? fileManager.attributesOfItem(atPath: url.path)

        if let attributes = attributes, let size = attributes[FileAttributeKey.size] as? UInt64 {
            self.size += size
        }

        self.updateDiskAccessDate(atPath: url.path)
        self.controlCapacity()
    }

    fileprivate func removeFile(atPath path: String) {
        let fileManager = FileManager.default
        do {
            let attributes: [FileAttributeKey: Any] = try fileManager.attributesOfItem(atPath: path)
            do {
                try fileManager.removeItem(atPath: path)
                if let fileSize = attributes[FileAttributeKey.size] as? UInt64 {
                    subtract(size: fileSize)
                }
            } catch {
            }
        } catch {
        }
    }

    @discardableResult fileprivate func updateDiskAccessDate(atPath path: String) -> Bool {
        let fileManager = FileManager.default
        let now = Date()
        do {
            try fileManager.setAttributes([FileAttributeKey.modificationDate: now], ofItemAtPath: path)
            return true
        } catch {
            return false
        }
    }
}

private func isNoSuchFileError(_ error: Error?) -> Bool {
    if let error = error {
        return NSCocoaErrorDomain == (error as NSError).domain && (error as NSError).code == NSFileReadNoSuchFileError
    }
    return false
}

extension FileManager {
    /// Used with DiskCache
    func enumerateContentsOfDirectory(atPath path: String, orderedByProperty property: String, ascending: Bool, usingBlock block: (URL, Int, inout Bool) -> Void ) {
        let directoryURL = URL(fileURLWithPath: path)
        do {
            let contents = try self.contentsOfDirectory(at: directoryURL,
                                                        includingPropertiesForKeys: [URLResourceKey(rawValue: property)],
                                                        options: FileManager.DirectoryEnumerationOptions())
            let sortedContents = contents.sorted(by: {(URL1: URL, URL2: URL) -> Bool  in
                var value1: AnyObject?
                do {
                    try (URL1 as NSURL).getResourceValue(&value1, forKey: URLResourceKey(rawValue: property))
                } catch {
                    return true
                }
                var value2: AnyObject?
                do {
                    try (URL2 as NSURL).getResourceValue(&value2, forKey: URLResourceKey(rawValue: property))
                } catch {
                    return false
                }

                if let string1 = value1 as? String, let string2 = value2 as? String {
                    return ascending ? string1 < string2: string2 < string1
                }

                if let date1 = value1 as? Date, let date2 = value2 as? Date {
                    return ascending ? date1 < date2: date2 < date1
                }

                if let number1 = value1 as? NSNumber, let number2 = value2 as? NSNumber {
                    return ascending ? number1.intValue < number2.intValue: number2.intValue < number1.intValue
                }

                return false
            })

            for (idx, value) in sortedContents.enumerated() {
                var stop: Bool = false
                block(value, idx, &stop)
                if stop { break }
            }

        } catch {
        }
    }
}
