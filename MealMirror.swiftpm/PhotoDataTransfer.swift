import Foundation
import PhotosUI
import SwiftUI

enum PhotoDataTransfer {
    enum Failure: Error { case timedOut }

    static func load(_ item: PhotosPickerItem) async throws -> Data? {
        try await load { completion in
            item.loadTransferable(type: Data.self, completionHandler: completion)
        }
    }

    // The start operation is separate so the deadline/cancellation contract can
    // be checked without reading anyone's photo library or decoding an image.
    static func load(
        start: @escaping @Sendable (@escaping @Sendable (Result<Data?, any Error>) -> Void) -> Progress
    ) async throws -> Data? {
        let gate = PhotoDataTransferGate()
        return try await withTaskCancellationHandler {
            try Task.checkCancellation()
            return try await withCheckedThrowingContinuation { continuation in
                guard gate.register(continuation) else { return }
                let deadline = DispatchWorkItem { [weak gate] in
                    gate?.finish(.failure(Failure.timedOut), cancelTransfer: true)
                }
                guard gate.register(deadline: deadline) else { return }
                DispatchQueue.global(qos: .utility).asyncAfter(deadline: .now() + 15, execute: deadline)
                DispatchQueue.global(qos: .userInitiated).async {
                    guard gate.isPending else { return }
                    let progress = start { result in gate.finish(result) }
                    gate.register(progress: progress)
                }
            }
        } onCancel: {
            gate.finish(.failure(CancellationError()), cancelTransfer: true)
        }
    }
}

// A provider may reply synchronously, after cancellation, more than once, or not
// at all. The first terminal result owns the continuation. Cancelling Progress
// requests provider cancellation; it does not guarantee that OS work has stopped.
private final class PhotoDataTransferGate: @unchecked Sendable {
    private let lock = NSLock()
    private var finished = false
    private var earlyResult: Result<Data?, any Error>?
    private var continuation: CheckedContinuation<Data?, any Error>?
    private var progress: Progress?
    private var deadline: DispatchWorkItem?
    private var cancelTransfer = false

    var isPending: Bool {
        lock.lock()
        defer { lock.unlock() }
        return !finished
    }

    func register(_ newContinuation: CheckedContinuation<Data?, any Error>) -> Bool {
        lock.lock()
        let pending = !finished
        let existing = earlyResult
        earlyResult = nil
        if pending { continuation = newContinuation }
        lock.unlock()
        if let existing { newContinuation.resume(with: existing) }
        return pending
    }

    func register(deadline newDeadline: DispatchWorkItem) -> Bool {
        lock.lock()
        let pending = !finished
        if pending { deadline = newDeadline }
        lock.unlock()
        if !pending { newDeadline.cancel() }
        return pending
    }

    func register(progress newProgress: Progress) {
        lock.lock()
        if !finished { progress = newProgress }
        let shouldCancel = cancelTransfer
        lock.unlock()
        if shouldCancel { newProgress.cancel() }
    }

    func finish(_ result: Result<Data?, any Error>, cancelTransfer shouldCancel: Bool = false) {
        lock.lock()
        guard !finished else { lock.unlock(); return }
        finished = true
        cancelTransfer = shouldCancel
        let currentContinuation = continuation
        let currentProgress = progress
        let currentDeadline = deadline
        // Only pre-registration cancellation needs a stored result. Do not keep
        // a successful encoded photo alive in a completed gate.
        if currentContinuation == nil { earlyResult = result }
        continuation = nil
        progress = nil
        deadline = nil
        lock.unlock()
        currentDeadline?.cancel()
        currentContinuation?.resume(with: result)
        if shouldCancel, let currentProgress {
            // A provider's cancellation handler can itself block. Returning
            // control must not depend on that handler finishing.
            DispatchQueue.global(qos: .utility).async { currentProgress.cancel() }
        }
    }
}
