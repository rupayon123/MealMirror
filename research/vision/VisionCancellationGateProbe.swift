import Foundation
private final class VisionContinuationGate<Result: Sendable>: @unchecked Sendable {
    private let lock = NSLock()
    private var continuation: CheckedContinuation<Result, Never>?
    private var request: VNRequest?
    private let fallback: Result

    init(continuation: CheckedContinuation<Result, Never>, fallback: Result) {
        self.continuation = continuation
        self.fallback = fallback
    }

    @discardableResult
    func resume(with result: Result) -> Bool {
        lock.lock()
        let currentContinuation = continuation
        continuation = nil
        request = nil
        lock.unlock()
        currentContinuation?.resume(returning: result)
        return currentContinuation != nil
    }

    func register(_ newRequest: VNRequest) -> Bool {
        lock.lock()
        let isPending = continuation != nil
        if isPending { request = newRequest }
        lock.unlock()
        if !isPending { newRequest.cancel() }
        return isPending
    }

    @discardableResult
    func cancelAndResume() -> Bool {
        lock.lock()
        let currentContinuation = continuation
        let currentRequest = request
        continuation = nil
        request = nil
        lock.unlock()
        currentContinuation?.resume(returning: fallback)
        if let currentRequest {
            // Returning the fallback must not wait for request cancellation.
            // Cancellation is a request; the underlying work may finish later.
            DispatchQueue.global(qos: .utility).async { currentRequest.cancel() }
        }
        return currentContinuation != nil
    }
}

import Foundation
import Darwin

private final class VNRequest: @unchecked Sendable {
    let entered = DispatchSemaphore(value: 0)
    let release = DispatchSemaphore(value: 0)
    let finished = DispatchSemaphore(value: 0)
    func cancel() { entered.signal(); release.wait(); finished.signal() }
}

private final class Shared: @unchecked Sendable {
    let lock = NSLock()
    var gate: VisionContinuationGate<String>?
    var value: String?
    let ready = DispatchSemaphore(value: 0)
    let returned = DispatchSemaphore(value: 0)
    func install(_ value: VisionContinuationGate<String>) { lock.lock(); gate = value; lock.unlock(); ready.signal() }
    func readGate() -> VisionContinuationGate<String> { lock.lock(); defer { lock.unlock() }; return gate! }
    func record(_ result: String) { lock.lock(); value = result; lock.unlock(); returned.signal() }
    func readValue() -> String? { lock.lock(); defer { lock.unlock() }; return value }
}

@main struct CancellationChecks {
    static func main() async throws {
        guard CommandLine.arguments.count == 2 else { exit(64) }
        DispatchQueue.global().asyncAfter(deadline: .now() + 15) { exit(124) }
        let state = Shared()
        let request = VNRequest()
        let task = Task.detached {
            let result = await withCheckedContinuation { continuation in
                let gate = VisionContinuationGate(continuation: continuation, fallback: "fallback")
                precondition(gate.register(request))
                state.install(gate)
            }
            state.record(result)
        }
        guard state.ready.wait(timeout: .now() + 2) == .success else { exit(65) }
        let gate = state.readGate()
        let callerReturned = DispatchSemaphore(value: 0)
        DispatchQueue.global().async { _ = gate.cancelAndResume(); callerReturned.signal() }
        guard request.entered.wait(timeout: .now() + 2) == .success else { request.release.signal(); exit(66) }
        // The request cancellation handler remains explicitly held during both checks.
        let resultBeforeRelease = state.returned.wait(timeout: .now() + 2) == .success
        let callerBeforeRelease = callerReturned.wait(timeout: .now() + 2) == .success
        request.release.signal()
        let cancellationFinished = request.finished.wait(timeout: .now() + 2) == .success
        await task.value
        let checks = ["fallbackBeforeCancellationRelease": resultBeforeRelease,
            "callerReturnsBeforeCancellationRelease": callerBeforeRelease,
            "handlerReleased": cancellationFinished,
            "fallbackValue": state.readValue() == "fallback",
            "lateResultRejected": !gate.resume(with: "late"),
            "secondCancellationRejected": !gate.cancelAndResume()]
        let result: [String: Any] = ["checks": checks, "passed": checks.values.allSatisfy { $0 },
            "scope": "Exact gate with declared blocking VNRequest spy. No real Vision, UIKit, app, Apple cancellation latency, OCR cause or OS stop proof."]
        try JSONSerialization.data(withJSONObject: result, options: [.prettyPrinted, .sortedKeys])
            .write(to: URL(fileURLWithPath: CommandLine.arguments[1]), options: .withoutOverwriting)
        exit(checks.values.allSatisfy { $0 } ? 0 : 1)
    }
}
