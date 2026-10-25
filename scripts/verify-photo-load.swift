// Run with scripts/verify-photo-load.py. The driver inserts the actual methods
// at runtime; this file contains declared Foundation-only spies and fixed checks.
// No PhotosUI, UIKit, decoder, memory or SwiftUI lifecycle equivalence is claimed.
import Darwin
import Foundation

private enum MealPhotoRole: String, Sendable { case food, label }
private struct UIImage: Sendable { let id: String }
private enum TransferOutcome: Sendable { case data, missing, failure }
private enum PlannedFailure: Error { case transfer }
private struct Plan: Sendable {
    var holdTransfer = false
    var holdDecode = false
    var transferOutcome: TransferOutcome = .data
    var decodeSucceeds = true
}
private struct PreparationCall: Sendable {
    let id: String
    let maxPixelSize: Int
}
private struct Calls: Sendable {
    let transfers: [String]
    let preparations: [PreparationCall]
    let events: [String]
}

private actor ProbeBackend {
    private var plans: [String: Plan] = [:]
    private var transferCalls: [String] = []
    private var preparationCalls: [PreparationCall] = []
    private var events: [String] = []
    private var witnesses: [String: [CheckedContinuation<Void, Never>]] = [:]
    private var heldTransfers: [String: CheckedContinuation<Data?, any Error>] = [:]
    private var heldDecodes: [String: CheckedContinuation<UIImage?, Never>] = [:]

    func install(_ newPlans: [String: Plan]) {
        precondition(newPlans.keys.allSatisfy { plans[$0] == nil })
        plans.merge(newPlans) { _, _ in fatalError("Duplicate fixture ID") }
    }

    private func witness(_ event: String) {
        events.append(event)
        for continuation in witnesses.removeValue(forKey: event) ?? [] {
            continuation.resume()
        }
    }

    func waitFor(_ event: String) async {
        if events.contains(event) { return }
        await withCheckedContinuation { witnesses[event, default: []].append($0) }
    }

    private func transferValue(_ id: String) throws -> Data? {
        switch plans[id]!.transferOutcome {
        case .data: return Data(id.utf8)
        case .missing: return nil
        case .failure: throw PlannedFailure.transfer
        }
    }

    func transfer(_ id: String) async throws -> Data? {
        precondition(plans[id] != nil)
        transferCalls.append(id)
        witness("transfer-start:" + id)
        if plans[id]!.holdTransfer {
            return try await withCheckedThrowingContinuation { heldTransfers[id] = $0 }
        }
        return try transferValue(id)
    }

    func releaseTransfer(_ id: String) {
        guard let continuation = heldTransfers.removeValue(forKey: id) else {
            fatalError("Transfer is not held: " + id)
        }
        witness("transfer-release:" + id)
        do { continuation.resume(returning: try transferValue(id)) }
        catch { continuation.resume(throwing: error) }
    }

    func prepare(_ data: Data, maxPixelSize: Int) async -> UIImage? {
        let id = String(decoding: data, as: UTF8.self)
        precondition(plans[id] != nil)
        preparationCalls.append(PreparationCall(id: id, maxPixelSize: maxPixelSize))
        witness("decode-start:" + id)
        if plans[id]!.holdDecode {
            return await withCheckedContinuation { heldDecodes[id] = $0 }
        }
        return plans[id]!.decodeSucceeds ? UIImage(id: id) : nil
    }

    func releaseDecode(_ id: String) {
        guard let continuation = heldDecodes.removeValue(forKey: id) else {
            fatalError("Decode is not held: " + id)
        }
        witness("decode-release:" + id)
        continuation.resume(returning: plans[id]!.decodeSucceeds ? UIImage(id: id) : nil)
    }

    func calls(prefix: String) -> Calls {
        Calls(transfers: transferCalls.filter { $0.hasPrefix(prefix) },
              preparations: preparationCalls.filter { $0.id.hasPrefix(prefix) },
              events: events.filter { $0.contains(prefix) })
    }
}

private let backend = ProbeBackend()

private struct PhotosPickerItem: Sendable {
    let id: String
    func loadTransferable(type: Data.Type) async throws -> Data? {
        try await backend.transfer(id)
    }
}

private enum MealPhotoPreparation {
    static func downsampledImageAsync(from data: Data, maxPixelSize: Int) async -> UIImage? {
        await backend.prepare(data, maxPixelSize: maxPixelSize)
    }
}

private struct AppendEvent: Equatable {
    let ids: [String]
    let role: MealPhotoRole
}
private struct StateSnapshot: Equatable {
    let token: UUID
    let busy: Bool
    let error: String?
    let appends: [AppendEvent]
    let stateWrites: Int
}

@MainActor
private final class PhotoLoadHarness {
    private var stateWrites = 0
    private var photoLoadToken = UUID() { didSet { stateWrites += 1 } }
    private var isPreparingPhoto = false { didSet { stateWrites += 1 } }
    private var photoLoadError: String? { didSet { stateWrites += 1 } }
    private var capturedTask: Task<Void, Never>?
    private var appends: [AppendEvent] = []
    private var foodPickerItems: [PhotosPickerItem] = []
    private var labelPickerItems: [PhotosPickerItem] = []

    func begin(_ ids: [String], role: MealPhotoRole = .food) -> Task<Void, Never> {
        loadSelectedPhotos(ids.map { PhotosPickerItem(id: $0) }, role: role)
        return capturedTask!
    }
    func invalidate() { invalidatePendingPhotoLoad() }
    func snapshot() -> StateSnapshot {
        StateSnapshot(token: photoLoadToken, busy: isPreparingPhoto, error: photoLoadError,
                      appends: appends, stateWrites: stateWrites)
    }
    private func cancelPendingAnalysis() {}
    private func appendPersonalPhotos(_ images: [UIImage], role: MealPhotoRole) {
        // Declared downstream spy: records an append and preserves only the
        // actual appender's invalidate-token/clear-busy contract. No app model.
        invalidatePendingPhotoLoad()
        appends.append(AppendEvent(ids: images.map(\.id), role: role))
    }

// __EXTRACTED_METHODS__
}

@MainActor
private final class Suite {
    var cases: [[String: Any]] = []
    var failures: [[String: Any]] = []

    func record(_ id: String, calls: Calls, checks: [(String, Bool)], state: StateSnapshot) {
        for (expectation, passed) in checks where !passed {
            failures.append(["case": id, "expectation": expectation])
        }
        cases.append(["id": id,
            "checks": checks.map { ["expectation": $0.0, "passed": $0.1] as [String: Any] },
            "transfers": calls.transfers,
            "preparations": calls.preparations.map { ["id": $0.id, "maxPixelSize": $0.maxPixelSize] as [String: Any] },
            "events": calls.events, "finalBusy": state.busy,
            "finalError": state.error as Any? ?? NSNull(),
            "appends": state.appends.map { ["ids": $0.ids, "role": $0.role.rawValue] as [String: Any] },
            "stateWriteCount": state.stateWrites])
    }
}

private func noLaterAWork(_ calls: Calls, prefix: String) -> Bool {
    let later = [prefix + "A2", prefix + "A3"]
    return !calls.transfers.contains(where: later.contains)
        && !calls.preparations.contains { later.contains($0.id) }
}

@MainActor
@main
private struct BaselineProbe {
    static func main() async throws {
        guard CommandLine.arguments.count == 2 else { fatalError("New report path required") }
        let reportURL = URL(fileURLWithPath: CommandLine.arguments[1])
        guard !FileManager.default.fileExists(atPath: reportURL.path) else { fatalError("Refusing existing report") }
        DispatchQueue.global(qos: .utility).asyncAfter(deadline: .now() + 20) { exit(124) }
        let suite = Suite()

        do {
            let id = "invalidatedDuringTransfer_completedB", p = id + "/"
            await backend.install([p + "A1": Plan(holdTransfer: true), p + "A2": Plan(), p + "A3": Plan(), p + "B1": Plan()])
            let h = PhotoLoadHarness()
            let a = h.begin([p + "A1", p + "A2", p + "A3"])
            await backend.waitFor("transfer-start:" + p + "A1")
            h.invalidate()
            let b = h.begin([p + "B1"])
            await b.value
            let completedB = h.snapshot()
            await backend.releaseTransfer(p + "A1")
            await a.value
            let final = h.snapshot(), calls = await backend.calls(prefix: p)
            suite.record(id, calls: calls, checks: [
                ("A1 does not start decode after transfer-time invalidation", !calls.preparations.contains { $0.id == p + "A1" }),
                ("A2/A3 do not start transfer or decode", noLaterAWork(calls, prefix: p)),
                ("Only B appends", final.appends == [AppendEvent(ids: [p + "B1"], role: .food)]),
                ("Completed B state has no stale writes", final == completedB),
                ("Completed B remains idle without error", !final.busy && final.error == nil)
            ], state: final)
        }

        do {
            let id = "invalidatedDuringDecode_activeB", p = id + "/"
            await backend.install([p + "A1": Plan(holdDecode: true), p + "A2": Plan(), p + "A3": Plan(), p + "B1": Plan(holdTransfer: true)])
            let h = PhotoLoadHarness()
            let a = h.begin([p + "A1", p + "A2", p + "A3"])
            await backend.waitFor("decode-start:" + p + "A1")
            h.invalidate()
            let b = h.begin([p + "B1"])
            await backend.waitFor("transfer-start:" + p + "B1")
            let activeB = h.snapshot()
            await backend.releaseDecode(p + "A1")
            await a.value
            let afterA = h.snapshot(), beforeBCalls = await backend.calls(prefix: p)
            await backend.releaseTransfer(p + "B1")
            await b.value
            let final = h.snapshot(), calls = await backend.calls(prefix: p)
            suite.record(id, calls: calls, checks: [
                ("Already-started A1 decode is allowed to finish once", beforeBCalls.preparations.filter { $0.id == p + "A1" }.count == 1),
                ("A2/A3 do not start transfer or decode", noLaterAWork(beforeBCalls, prefix: p)),
                ("A never appends while B is active", afterA.appends.isEmpty),
                ("B remains busy with no stale error", afterA.busy && afterA.error == nil),
                ("Active B state has no stale writes", afterA == activeB),
                ("Only B appends after release", final.appends == [AppendEvent(ids: [p + "B1"], role: .food)]),
                ("B completes idle without error", !final.busy && final.error == nil)
            ], state: final)
        }

        do {
            let id = "staleTransferFailure_completedB", p = id + "/"
            await backend.install([p + "A1": Plan(holdTransfer: true, transferOutcome: .failure), p + "A2": Plan(), p + "A3": Plan(), p + "B1": Plan()])
            let h = PhotoLoadHarness(), a = h.begin([p + "A1", p + "A2", p + "A3"])
            await backend.waitFor("transfer-start:" + p + "A1")
            h.invalidate()
            let b = h.begin([p + "B1"])
            await b.value
            let completedB = h.snapshot()
            await backend.releaseTransfer(p + "A1")
            await a.value
            let final = h.snapshot(), calls = await backend.calls(prefix: p)
            suite.record(id, calls: calls, checks: [
                ("Completed B has no stale state/error/busy write", final == completedB),
                ("Only B appends", final.appends == [AppendEvent(ids: [p + "B1"], role: .food)]),
                ("Failed A transfer never decodes", !calls.preparations.contains { $0.id.hasPrefix(p + "A") }),
                ("A2/A3 never start", noLaterAWork(calls, prefix: p))
            ], state: final)
        }

        do {
            let id = "staleDecodeFailure_completedB", p = id + "/"
            await backend.install([p + "A1": Plan(holdDecode: true, decodeSucceeds: false), p + "A2": Plan(), p + "A3": Plan(), p + "B1": Plan()])
            let h = PhotoLoadHarness(), a = h.begin([p + "A1", p + "A2", p + "A3"])
            await backend.waitFor("decode-start:" + p + "A1")
            h.invalidate()
            let b = h.begin([p + "B1"])
            await b.value
            let completedB = h.snapshot()
            await backend.releaseDecode(p + "A1")
            await a.value
            let final = h.snapshot(), calls = await backend.calls(prefix: p)
            suite.record(id, calls: calls, checks: [
                ("Completed B has no stale state/error/busy write", final == completedB),
                ("Only B appends", final.appends == [AppendEvent(ids: [p + "B1"], role: .food)]),
                ("Only already-started A1 decode occurred", calls.preparations.filter { $0.id.hasPrefix(p + "A") }.map(\.id) == [p + "A1"]),
                ("A2/A3 never start", noLaterAWork(calls, prefix: p))
            ], state: final)
        }

        for role in [MealPhotoRole.food, .label] {
            let id = role == .food ? "activeFoodSuccess" : "activeLabelSuccess", p = id + "/"
            let ids = role == .food ? [p + "F1", p + "F2"] : [p + "L1"]
            await backend.install(Dictionary(uniqueKeysWithValues: ids.map { ($0, Plan()) }))
            let h = PhotoLoadHarness(), task = h.begin(ids, role: role)
            await task.value
            let final = h.snapshot(), calls = await backend.calls(prefix: p)
            suite.record(id, calls: calls, checks: [
                ("One append preserves IDs, order and role", final.appends == [AppendEvent(ids: ids, role: role)]),
                ("Busy clears", !final.busy),
                ("No error", final.error == nil),
                ("Expected role limit for each preparation", calls.preparations.map(\.id) == ids && calls.preparations.allSatisfy { $0.maxPixelSize == (role == .label ? 2_400 : 1_800) })
            ], state: final)
        }

        do {
            let id = "activeTransferFailure", p = id + "/"
            await backend.install([p + "F1": Plan(transferOutcome: .failure)])
            let h = PhotoLoadHarness(), task = h.begin([p + "F1"])
            await task.value
            let final = h.snapshot(), calls = await backend.calls(prefix: p)
            suite.record(id, calls: calls, checks: [
                ("No append", final.appends.isEmpty), ("Busy clears", !final.busy),
                ("Error shown", final.error != nil), ("No decode", calls.preparations.isEmpty)
            ], state: final)
        }

        do {
            let id = "activeDecodeFailure", p = id + "/"
            await backend.install([p + "F1": Plan(decodeSucceeds: false)])
            let h = PhotoLoadHarness(), task = h.begin([p + "F1"])
            await task.value
            let final = h.snapshot(), calls = await backend.calls(prefix: p)
            suite.record(id, calls: calls, checks: [
                ("No append", final.appends.isEmpty), ("Busy clears", !final.busy),
                ("Error shown", final.error != nil), ("One failed preparation", calls.preparations.map(\.id) == [p + "F1"])
            ], state: final)
        }

        let checkCount = suite.cases.reduce(0) { $0 + ($1["checks"] as! [[String: Any]]).count }
        let report: [String: Any] = ["schemaVersion": 1, "phase": "completed",
            "scope": "Foundation-only actual loading-method mechanics with declared ID-only transfer/preparation/appender spies; not SwiftUI lifecycle, real PhotosUI/decoding, memory, cancellation of in-flight compute or app UI proof.",
            "ordering": "Explicit checked-continuation witnesses/releases; no ordering sleeps.",
            "caseCount": suite.cases.count, "checkCount": checkCount,
            "failureCount": suite.failures.count, "failures": suite.failures, "cases": suite.cases]
        try JSONSerialization.data(withJSONObject: report, options: [.prettyPrinted, .sortedKeys])
            .write(to: reportURL, options: .atomic)
        print("\(suite.cases.count) cases, \(checkCount) checks, \(suite.failures.count) failed expectations")
        exit(suite.failures.isEmpty ? 0 : 1)
    }
}
