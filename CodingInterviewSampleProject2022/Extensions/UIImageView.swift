//
//  UIImageView.swift
//  CodingInterviewSampleProject2022
//
//  Created by Sandeep on 07/03/24.
//

import Foundation
import UIKit

// MARK: - Associated Object
private var taskIdentifierKey: Void?

class Box<T> {
    var value: T

    init(_ value: T) {
        self.value = value
    }
}

extension UIImageView {
    private(set) var taskIdentifier: ResourceDownloadable.Identifier.Value? {
        get {
            let box: Box<ResourceDownloadable.Identifier.Value>? = getAssociatedObject(self, &taskIdentifierKey)
            return box?.value
        }
        set {
            let box = newValue.map { Box($0) }
            setRetainedAssociatedObject(self, &taskIdentifierKey, box)
        }
    }

    private func getAssociatedObject<T>(_ object: Any, _ key: UnsafeRawPointer) -> T? {
        return objc_getAssociatedObject(object, key) as? T
    }

    private func setRetainedAssociatedObject<T>(_ object: Any, _ key: UnsafeRawPointer, _ value: T) {
        objc_setAssociatedObject(object, key, value, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }

    private func loadImage(toImage: UIImage?, animated: Bool = true) {
        if animated {
            UIView.transition(with: self,
                              duration: 0.25,
                              options: [.transitionCrossDissolve, .curveEaseIn, .allowUserInteraction],
                              animations: { self.image = toImage },
                              completion: nil)
        } else {
            self.image = toImage
        }
    }

    func setImage(withURL url: URL?, placeholderImage: UIImage? = nil, queuePriority: Operation.QueuePriority? = nil, animated: Bool = true, oldIdentifier: ResourceDownloadable.Identifier.Value? = nil, completion: ((Bool, Error?) -> Void)? = nil) {
        guard let downloadURL = url else {
            completion?(false, AppDownloadError.canceled)
            return
        }

        let file = ResourceDownloadable(downloadURL: downloadURL)
        guard let filePath = file.filePath()?.path else {
            completion?(false, AppDownloadError.canceled)
            return
        }

        if file.fileExists(), let toImage = UIImage(contentsOfFile: filePath) {
            DispatchQueue.main.async {
                self.loadImage(toImage: toImage, animated: animated)
                completion?(true, nil)
            }
        } else {
            let issuedIdentifier = oldIdentifier ?? ResourceDownloadable.Identifier.next()
            self.taskIdentifier = issuedIdentifier

            DownloadManager.shared.retrieveImage(withURL: downloadURL, queuePriority: queuePriority) { [weak self] result in
                guard let weakSelf = self, issuedIdentifier == weakSelf.taskIdentifier else {
                    completion?(false, nil) // Task was cancelled or not matching the identifier
                    return
                }
                weakSelf.taskIdentifier = nil
                switch result {
                case .success(let success):
                    DispatchQueue.main.async {
                        weakSelf.loadImage(toImage: success.image, animated: animated)
                        completion?(true, nil)
                    }
                case .failure(let failure):
                    completion?(false, failure)
                }
            }
        }
    }

}
