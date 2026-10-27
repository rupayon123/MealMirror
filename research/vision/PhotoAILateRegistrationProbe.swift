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

enum PhotoAIStatus { case timeout }
private final class Box: @unchecked Sendable {
    let lock = NSLock()
    var value: CheckedContinuation<Void, Never>?
    func set(_ x: CheckedContinuation<Void, Never>) { lock.lock(); value=x; lock.unlock() }
    func release() { lock.lock(); let x=value; value=nil; lock.unlock(); x?.resume() }
}
@main struct Probe {
    static func run(timer: Bool) -> [String: Bool] {
        let gate=PhotoAIContinuationGate()
        gate.finish(.timeout)
        let ready=DispatchSemaphore(value:0), entered=DispatchSemaphore(value:0)
        let release=DispatchSemaphore(value:0), returned=DispatchSemaphore(value:0)
        let exited=DispatchSemaphore(value:0), handlerExited=DispatchSemaphore(value:0)
        let box=Box()
        let task=Task.detached {
            await withTaskCancellationHandler {
                await withCheckedContinuation { c in box.set(c); ready.signal() }
            } onCancel: {
                entered.signal(); release.wait(); handlerExited.signal()
            }
            exited.signal()
        }
        guard ready.wait(timeout:.now()+2) == .success else { return ["setup":false] }
        DispatchQueue.global().async {
            if timer { gate.register(timer:task) } else { gate.register(worker:task) }
            returned.signal()
        }
        let didEnter=entered.wait(timeout:.now()+2) == .success
        let earlyReturn=returned.wait(timeout:.now()+1) == .success
        release.signal()
        let cleaned=handlerExited.wait(timeout:.now()+2) == .success
        if !earlyReturn { _=returned.wait(timeout:.now()+2) }
        box.release()
        let stopped=exited.wait(timeout:.now()+2) == .success
        withExtendedLifetime(task) {}
        return ["cancellationHandlerEntered":didEnter,"registrationReturnedBeforeRelease":earlyReturn,"handlerReleased":cleaned,"taskExitedAfterOperationRelease":stopped]
    }
    static func main() {
        let worker=run(timer:false),timer=run(timer:true)
        let passed=worker.values.allSatisfy{$0} && timer.values.allSatisfy{$0}
        let data=try! JSONSerialization.data(withJSONObject:["worker":worker,"timer":timer,"passed":passed],options:[.sortedKeys])
        print(String(decoding:data,as:UTF8.self));exit(passed ? 0:1)
    }
}
