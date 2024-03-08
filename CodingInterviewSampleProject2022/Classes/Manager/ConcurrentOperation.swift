//
//  ConcurrentOperation.swift
//  CodingInterviewSampleProject2022
//
//  Created by Sandeep on 07/03/24.
//

import Foundation

class ConcurrentOperation: Operation {
    @objc private enum OperationState: Int {
        case ready
        case executing
        case finished
    }

    /// Concurrent queue for synchronizing access to `state`.
    private let stateQueue = DispatchQueue(label: Bundle.main.bundleIdentifier! + ".rw.state", attributes: .concurrent)

    /// Private backing stored property for `state`.
    private var rawState: OperationState = .ready

    /// The state of the operation
    @objc private dynamic var state: OperationState {
        get { return stateQueue.sync { rawState } }
        set { stateQueue.sync(flags: .barrier) { rawState = newValue } }
    }

    // MARK: - Various `Operation` properties

    override var isReady: Bool {
        return super.isReady && state == .ready
    }
    override var isExecuting: Bool {
        return state == .executing
    }
    override var isFinished: Bool {
        return state == .finished
    }
    override var isAsynchronous: Bool {
        return true
    }

    // MARK: - KVN for dependent properties

    @objc private dynamic class func keyPathsForValuesAffectingIsReady() -> Set<String> {
        return [#keyPath(state)]
    }

    @objc private dynamic class func keyPathsForValuesAffectingIsExecuting() -> Set<String> {
        return [#keyPath(state)]
    }

    @objc private dynamic class func keyPathsForValuesAffectingIsFinished() -> Set<String> {
        return [#keyPath(state)]
    }

    // MARK: - Foundation.Operation

    override func start() {
        guard !isCancelled else {
            finish()
            return
        }

        state = .executing
        main()
    }

    override func cancel() {
        super.cancel()
        finish()
    }

    /// Call this function to finish an operation that is currently executing
    func finish() {
        if isExecuting { state = .finished }
    }
}
