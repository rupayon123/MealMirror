import Foundation
private final class PhotoAIContinuationGate: @unchecked Sendable {
    private let lock = NSLock()
    private var result: PhotoAIStatus?
    private var continuation: CheckedContinuation<PhotoAIStatus, Never>?
    private var worker: Task<Void, Never>?
    private var timer: Task<Void, Never>?

    func register(_ newContinuation: CheckedContinuation<PhotoAIStatus, Never>) -> Bool {
        lock.lock()
        let existingResult = result
        if existingResult == nil { continuation = newContinuation }
        lock.unlock()
        if let existingResult { newContinuation.resume(returning: existingResult) }
        return existingResult == nil
    }

    func register(worker newWorker: Task<Void, Never>) {
        lock.lock()
        let pending = result == nil
        if pending { worker = newWorker }
        lock.unlock()
        if !pending { Self.cancelAsynchronously(newWorker) }
    }

    func register(timer newTimer: Task<Void, Never>) {
        lock.lock()
        let pending = result == nil
        if pending { timer = newTimer }
        lock.unlock()
        if !pending { Self.cancelAsynchronously(newTimer) }
    }

    func finish(_ value: PhotoAIStatus) {
        lock.lock()
        guard result == nil else { lock.unlock(); return }
        result = value
        let currentContinuation = continuation
        let currentWorker = worker
        let currentTimer = timer
        continuation = nil
        worker = nil
        timer = nil
        lock.unlock()
        currentContinuation?.resume(returning: value)
        Self.cancelAsynchronously(currentWorker)
        Self.cancelAsynchronously(currentTimer)
    }

    private static func cancelAsynchronously(_ task: Task<Void, Never>?) {
        guard let task else { return }
        // Cancellation handlers can run synchronously. Never make delivery or
        // late registration wait for a worker's cancellation handler to return.
        DispatchQueue.global(qos: .utility).async { task.cancel() }
    }
}

// Foundation-only gate check. The status enum is a declared test surrogate;
// the Task and its synchronous cancellation handler use the real Swift runtime.
enum PhotoAIStatus: String { case timeout, late }

private final class Box<T>: @unchecked Sendable {
    private let lock = NSLock()
    private var value: T?
    func set(_ newValue: T) { lock.lock(); value = newValue; lock.unlock() }
    func get() -> T? { lock.lock(); defer { lock.unlock() }; return value }
}

@main struct Probe {
    static func main() {
        let gate = PhotoAIContinuationGate()
        let registered = DispatchSemaphore(value: 0)
        let fallbackReturned = DispatchSemaphore(value: 0)
        let workerReady = DispatchSemaphore(value: 0)
        let cancelEntered = DispatchSemaphore(value: 0)
        let cancelRelease = DispatchSemaphore(value: 0)
        let cancelExited = DispatchSemaphore(value: 0)
        let finishReturned = DispatchSemaphore(value: 0)
        let workerExited = DispatchSemaphore(value: 0)
        let result = Box<PhotoAIStatus>()
        let suspend = Box<CheckedContinuation<Void, Never>>()
        let observer = Task.detached {
            let value: PhotoAIStatus = await withCheckedContinuation { continuation in
                _ = gate.register(continuation)
                registered.signal()
            }
            result.set(value)
            fallbackReturned.signal()
        }
        let worker = Task.detached {
            await withTaskCancellationHandler {
                await withCheckedContinuation { continuation in
                    suspend.set(continuation)
                    workerReady.signal()
                }
            } onCancel: {
                cancelEntered.signal()
                cancelRelease.wait()
                cancelExited.signal()
            }
            workerExited.signal()
        }
        guard registered.wait(timeout: .now() + 2) == .success,
              workerReady.wait(timeout: .now() + 2) == .success else {
            print("{\"setupFailed\":true}"); exit(2)
        }
        gate.register(worker: worker)
        DispatchQueue.global().async {
            gate.finish(.timeout)
            finishReturned.signal()
        }
        let entered = cancelEntered.wait(timeout: .now() + 2) == .success
        let deliveredBeforeRelease = fallbackReturned.wait(timeout: .now() + 1) == .success
        let finishedBeforeRelease = finishReturned.wait(timeout: .now() + 1) == .success
        // Retain a conflicting late result while cancellation is held.
        gate.finish(.late)
        cancelRelease.signal()
        let cleanup = cancelExited.wait(timeout: .now() + 2) == .success
        if !deliveredBeforeRelease { _ = fallbackReturned.wait(timeout: .now() + 2) }
        if !finishedBeforeRelease { _ = finishReturned.wait(timeout: .now() + 2) }
        suspend.get()?.resume()
        let workerStopped = workerExited.wait(timeout: .now() + 2) == .success
        let lateRegistered = DispatchSemaphore(value: 0)
        let lateValue = Box<PhotoAIStatus>()
        let lateObserver = Task.detached {
            let value: PhotoAIStatus = await withCheckedContinuation { continuation in
                _ = gate.register(continuation)
            }
            lateValue.set(value)
            lateRegistered.signal()
        }
        let lateReturned = lateRegistered.wait(timeout: .now() + 2) == .success
        let checks: [String: Bool] = [
            "cancellationHandlerEntered": entered,
            "fallbackDeliveredBeforeCancellationRelease": deliveredBeforeRelease,
            "finishReturnedBeforeCancellationRelease": finishedBeforeRelease,
            "cancellationHandlerReleased": cleanup,
            "workerExitedAfterOperationReleased": workerStopped,
            "originalFallbackPreserved": result.get() == .timeout,
            "lateRegistrationReturnsOriginalResult": lateReturned && lateValue.get() == .timeout
        ]
        let data = try! JSONSerialization.data(withJSONObject: ["checks": checks, "passed": checks.values.allSatisfy { $0 }], options: [.sortedKeys])
        print(String(decoding: data, as: UTF8.self))
        withExtendedLifetime((observer, worker, lateObserver)) {}
        exit(checks.values.allSatisfy { $0 } ? 0 : 1)
    }
}
