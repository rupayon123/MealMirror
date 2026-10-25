// Appended byte-for-byte after the actual helper by verify-photo-transfer.py.
// Real Foundation locks/tasks/timer/Progress, synthetic providers only. No UI,
// Photos library, image decoding, network, model or physical-device acceptance.
import Darwin

private actor Signal {
    private var fired = false
    private var waiters: [CheckedContinuation<Void, Never>] = []
    func send() { fired = true; let pending = waiters; waiters = []; pending.forEach { $0.resume() } }
    func wait() async {
        if fired { return }
        await withCheckedContinuation { waiters.append($0) }
    }
}

private enum ProbeError: Error { case supplied }
private enum Outcome: Equatable { case data(Data?), cancelled, timedOut, suppliedError, otherError }
private func outcome(_ work: @Sendable () async throws -> Data?) async -> Outcome {
    do { return .data(try await work()) }
    catch is CancellationError { return .cancelled }
    catch PhotoDataTransfer.Failure.timedOut { return .timedOut }
    catch ProbeError.supplied { return .suppliedError }
    catch { return .otherError }
}

private final class Provider: @unchecked Sendable {
    let started = Signal()
    let cancellationBegan = Signal()
    let cancellationEnded = Signal()
    let progress = Progress(totalUnitCount: 1)
    private let lock = NSLock()
    private var callback: (@Sendable (Result<Data?, any Error>) -> Void)?
    private var starts = 0
    private let startRelease = DispatchSemaphore(value: 0)
    private let cancelRelease = DispatchSemaphore(value: 0)
    private let holdStart: Bool
    private let holdCancel: Bool

    init(holdStart: Bool = false, holdCancel: Bool = false) {
        self.holdStart = holdStart; self.holdCancel = holdCancel
        progress.cancellationHandler = { [weak self] in
            guard let self else { return }
            Task { await self.cancellationBegan.send() }
            if self.holdCancel { self.cancelRelease.wait() }
            Task { await self.cancellationEnded.send() }
        }
    }
    var startCount: Int { lock.lock(); defer { lock.unlock() }; return starts }
    func start(_ completion: @escaping @Sendable (Result<Data?, any Error>) -> Void) -> Progress {
        lock.lock(); starts += 1; callback = completion; lock.unlock()
        Task { await started.send() }
        if holdStart { startRelease.wait() }
        return progress
    }
    func reply(_ result: Result<Data?, any Error>) {
        lock.lock(); let current = callback; lock.unlock(); current?(result)
    }
    func releaseStart() { startRelease.signal() }
    func releaseCancel() { cancelRelease.signal() }
}

@main
private struct TransferChecks {
    static func main() async throws {
        guard CommandLine.arguments.count == 2 else { exit(64) }
        let reportURL = URL(fileURLWithPath: CommandLine.arguments[1])
        guard !FileManager.default.fileExists(atPath: reportURL.path) else { exit(65) }
        DispatchQueue.global(qos: .utility).asyncAfter(deadline: .now() + 60) { exit(124) }
        var cases: [[String: Any]] = []
        func record(_ id: String, _ checks: [(String, Bool)]) {
            cases.append(["id": id, "checks": checks.map { ["expectation": $0.0, "passed": $0.1] }])
        }
        let first = Data([1]), second = Data([2])

        do {
            let progress = Progress(totalUnitCount: 1)
            let value = await outcome { try await PhotoDataTransfer.load { completion in
                completion(.success(first)); return progress
            } }
            record("synchronousData", [("Exact bytes returned", value == .data(first)), ("Successful progress not cancelled", !progress.isCancelled)])
        }
        do {
            let value = await outcome { try await PhotoDataTransfer.load { completion in
                completion(.success(nil)); return Progress(totalUnitCount: 1)
            } }
            record("synchronousNil", [("Nil remains nil", value == .data(nil))])
        }
        do {
            let value = await outcome { try await PhotoDataTransfer.load { completion in
                completion(.failure(ProbeError.supplied)); return Progress(totalUnitCount: 1)
            } }
            record("providerError", [("Provider error retained", value == .suppliedError)])
        }
        do {
            let value = await outcome { try await PhotoDataTransfer.load { completion in
                completion(.success(first)); completion(.success(second)); return Progress(totalUnitCount: 1)
            } }
            record("duplicateReply", [("First terminal reply wins", value == .data(first))])
        }
        do {
            let barrier = Signal(), provider = Provider()
            let task = Task { await barrier.wait(); return await outcome { try await PhotoDataTransfer.load(start: provider.start) } }
            task.cancel(); await barrier.send()
            let value = await task.value
            record("preCancelled", [("Cancellation returned", value == .cancelled), ("Provider not started", provider.startCount == 0)])
        }
        do {
            let provider = Provider(holdStart: true)
            let task = Task { await outcome { try await PhotoDataTransfer.load(start: provider.start) } }
            await provider.started.wait(); task.cancel()
            let value = await task.value
            let beforeReturn = provider.progress.isCancelled
            provider.releaseStart(); await provider.cancellationEnded.wait()
            provider.reply(.success(first))
            record("cancelBeforeProgressReturns", [("Caller returns while factory is held", value == .cancelled),
                ("Progress not yet available to cancel", !beforeReturn), ("Late progress cancelled", provider.progress.isCancelled)])
        }
        do {
            let provider = Provider(holdCancel: true), gate = PhotoDataTransferGate()
            gate.register(progress: provider.progress)
            let value = await outcome { try await withCheckedThrowingContinuation { continuation in
                _ = gate.register(continuation)
                gate.finish(.failure(CancellationError()), cancelTransfer: true)
            } }
            await provider.cancellationBegan.wait()
            provider.releaseCancel(); await provider.cancellationEnded.wait()
            record("blockingCancellationHandler", [("Caller returns without handler finishing", value == .cancelled), ("Cancellation requested", provider.progress.isCancelled)])
        }
        do {
            let provider = Provider()
            let started = ProcessInfo.processInfo.systemUptime
            let value = await outcome { try await PhotoDataTransfer.load(start: provider.start) }
            let elapsed = ProcessInfo.processInfo.systemUptime - started
            await provider.cancellationEnded.wait()
            provider.reply(.success(first))
            record("actualFifteenSecondDeadline", [("Timeout returned without a provider reply", value == .timedOut), ("Progress cancellation requested", provider.progress.isCancelled)])
            cases[cases.count - 1]["elapsedSeconds"] = elapsed
        }
        do {
            let gate = PhotoDataTransferGate(), progress = Progress(totalUnitCount: 1)
            gate.finish(.failure(PhotoDataTransfer.Failure.timedOut), cancelTransfer: true)
            let value = await outcome { try await withCheckedThrowingContinuation { continuation in
                _ = gate.register(continuation)
            } }
            gate.register(progress: progress)
            let deadline = DispatchWorkItem {}
            let pending = gate.register(deadline: deadline)
            gate.finish(.success(first))
            record("timeoutBeforeRegistration", [("Early timeout delivered", value == .timedOut), ("Late progress cancelled", progress.isCancelled),
                ("Late deadline rejected and cancelled", !pending && deadline.isCancelled)])
        }
        do {
            let gate = PhotoDataTransferGate(), progress = Progress(totalUnitCount: 1)
            let value = await outcome { try await withCheckedThrowingContinuation { continuation in
                _ = gate.register(continuation); gate.finish(.success(first))
            } }
            gate.finish(.failure(CancellationError()), cancelTransfer: true)
            gate.register(progress: progress)
            record("successBeforeCancellation", [("Successful result retained", value == .data(first)), ("Late cancellation cannot change winner", !progress.isCancelled)])
        }
        let checks = cases.flatMap { $0["checks"] as! [[String: Any]] }
        let failures = checks.filter { ($0["passed"] as? Bool) != true }.count
        let report: [String: Any] = ["scope": "Actual helper/gate with synthetic completion providers and native Foundation; no Photos library/UI or image/physical proof.",
            "caseCount": cases.count, "checkCount": checks.count, "failureCount": failures, "cases": cases]
        try JSONSerialization.data(withJSONObject: report, options: [.prettyPrinted, .sortedKeys]).write(to: reportURL, options: .atomic)
        print("\(cases.count) cases, \(checks.count) checks, \(failures) failed expectations")
        exit(failures == 0 ? 0 : 1)
    }
}
