//
//  DownloadManager.swift
//  CodingInterviewSampleProject2022
//
//  Created by Sandeep on 07/03/24.
//

import Foundation
import UIKit

enum AppDownloadError: Error {
    case fileNotFound(url: URL)
    case imageLoadFailed(url: URL)
    case canceled
}

class DownloadManager {
    static let shared = DownloadManager()

    // Capped concurrency downloading queue
    lazy var downloadQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.qualityOfService = .userInitiated
        queue.maxConcurrentOperationCount = 20
        return queue
    }()

    // Uncapped loading queue
    lazy var loadingQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.qualityOfService = .userInitiated
        return queue
    }()


    func retrieveImage(withURL url: URL, onlyFromCache: Bool = false, queuePriority: Operation.QueuePriority? = nil, completion: @escaping (Result<ImageDownloadResult, Error>) -> Void) {
        let resource = ResourceDownloadable(downloadURL: url)
        guard let filePath = resource.filePath()?.path else {
            completion(.failure(AppDownloadError.fileNotFound(url: url)))
            return
        }

        if onlyFromCache {
            if resource.fileExists() {
                DispatchQueue.main.async {
                    if let toImage = UIImage(contentsOfFile: filePath) {
                        let downloadResult = ImageDownloadResult(downloadURL: url, image: toImage)
                        completion(.success(downloadResult))
                    } else {
                        completion(.failure(AppDownloadError.imageLoadFailed(url: url)))
                    }
                }
            } else {
                completion(.failure(AppDownloadError.fileNotFound(url: url)))
            }
        } else {
            download(resource, queuePriority: queuePriority) {
                DispatchQueue.main.async {
                    guard FileManager.default.fileExists(atPath: filePath),
                          let toImage = UIImage(contentsOfFile: filePath) else {
                        completion(.failure(AppDownloadError.fileNotFound(url: url)))
                        return
                    }

                    let downloadResult = ImageDownloadResult(downloadURL: url, image: toImage)
                    completion(.success(downloadResult))
                }
            }
        }
    }
    func download(withURL url: URL, queuePriority: Operation.QueuePriority? = nil) {
        download(ResourceDownloadable(downloadURL: url), queuePriority: queuePriority)
    }

    func cancel(withURL url: URL) {
        cancel(ResourceDownloadable(downloadURL: url))
    }

    // Download if needed, completion callback when file is ready. Will add a loading operation to the queue instead if there is already a download operation for the specified file.
   private func download(_ downloadable: DownloadableFile, queuePriority: Operation.QueuePriority? = nil, completion: (() -> Void)? = nil) {
        if downloadable.fileExists() {
            completion?()
            return
        }

        guard let file = ResourceDownloadable(file: downloadable) else {
            completion?()
            return
        }

        self.resourcedownload(file, queuePriority: queuePriority, completion: completion)
    }

    func resourcedownload(_ downloadable: ResourceDownloadable, queuePriority: Operation.QueuePriority? = nil, completion: (() -> Void)? = nil) {
        if downloadable.fileExists() {
            completion?()
            return
        }

        let newOperation = DownloadOperation(downloadable, completion: completion)
        if let loadQueuePriority = queuePriority { newOperation.queuePriority = loadQueuePriority }

        for operation in downloadQueue.operations where operation == newOperation && !operation.isCancelled {
            if completion != nil {
                let loadOperation = LoadOperation(downloadable, completion: completion)
                loadOperation.addDependency(operation)
                loadingQueue.addOperation(loadOperation)
            }
            return
        }

        downloadQueue.addOperation(newOperation)
    }

   private func cancel(_ downloadable: ResourceDownloadable) {
        let newOperation = DownloadOperation(downloadable, completion: nil)
        for operation in downloadQueue.operations where operation == newOperation && !operation.isCancelled {
            operation.cancel()
        }

        let loadOperation = LoadOperation(downloadable)
        for operation in loadingQueue.operations where operation == loadOperation && !operation.isCancelled {
            for dependency in operation.dependencies {
                operation.removeDependency(dependency)
            }
            operation.cancel()
        }
    }

    func cancelPendingDownloads() {
        downloadQueue.operations.forEach {
            if $0.isReady { $0.cancel() }
        }
        loadingQueue.operations.forEach {
            if $0.isReady { $0.cancel() }
        }
    }

    func cancelDownloads() {
        downloadQueue.cancelAllOperations()
        loadingQueue.cancelAllOperations()
    }
}

