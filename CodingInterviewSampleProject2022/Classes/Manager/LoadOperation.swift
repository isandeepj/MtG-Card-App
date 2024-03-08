//
//  LoadOperation.swift
//  CodingInterviewSampleProject2022
//
//  Created by Sandeep on 07/03/24.
//

import Foundation

/// Operation for loading, depending on a download operation.
class LoadOperation: ConcurrentOperation {
    var downloadableFile: ResourceDownloadable

    init(_ downloadableFile: ResourceDownloadable, completion: (() -> Void)? = nil) {
        self.downloadableFile = downloadableFile
        super.init()
        self.completionBlock = completion
    }

    override func main() {
        if downloadableFile.fileExists() {
            self.finish()
        } else {
            // This shouldn't happen!
            self.finish()
        }
    }

    override func isEqual(_ object: Any?) -> Bool {
        guard let rhsOperation = object as? LoadOperation else { return false }
        let lhsFile = self.downloadableFile
        let rhsFile = rhsOperation.downloadableFile
        return lhsFile == rhsFile
    }
}
