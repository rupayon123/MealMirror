import CoreImage
import CoreML
import CryptoKit
import Darwin
import Dispatch
import Foundation
import ImageIO
import Vision

/// Native macOS CGImage route for the frozen direct Vision A1-B-A2 diagnostic.
@main struct NativeMacVisionProbe {
    static func main() async {
        let args = CommandLine.arguments
        guard args.count == 3 else { _exit(3) }
        let os = ProcessInfo.processInfo.operatingSystemVersion
        guard os.majorVersion == 27 else { _exit(3) }
        let fixtureDirectory = URL(fileURLWithPath: args[1], isDirectory: true)
        let documents = URL(fileURLWithPath: args[2], isDirectory: true)
        let names = ["direct-vision-multi.json", "direct-vision-multi.attempt", "A1.bin", "B.bin", "A2.bin"]
        guard FileManager.default.fileExists(atPath: fixtureDirectory.path),
              FileManager.default.fileExists(atPath: documents.path),
              names.allSatisfy({ !FileManager.default.fileExists(atPath: documents.appendingPathComponent($0).path) }) else { _exit(4) }
        do {
            try Data("direct-vision-multi-v1; native Mac A1-B-A2 once; no retries\n".utf8)
                .write(to: documents.appendingPathComponent("direct-vision-multi.attempt"), options: .withoutOverwriting)
        } catch { _exit(5) }
        let output = documents.appendingPathComponent("direct-vision-multi.json")
        DirectVisionMultiWorker.persist(["schemaVersion": 1, "protocol": "direct-vision-multi-v1",
            "executionHostKind": "nativeMacOS", "phase": "scheduled",
            "maximumPerformCalls": 3, "performEntryCheckpoints": 0,
            "orderedCaseIDs": ["A1", "B", "A2"]], output)
        let watchdog = DispatchSource.makeTimerSource(queue: .global(qos: .utility))
        watchdog.schedule(deadline: .now() + 45)
        watchdog.setEventHandler { _exit(124) }
        watchdog.resume()
        let systemVersion = ProcessInfo.processInfo.operatingSystemVersionString
        let code = await Task.detached(priority: .utility) {
            DirectVisionMultiWorker.execute(documents: documents, fixtureDirectory: fixtureDirectory,
                                            systemVersion: systemVersion)
        }.value
        watchdog.cancel()
        _exit(code)
    }
}

private enum DirectVisionMultiWorker {
    private static let fixtures = [
        "F01": "aa0718f05333bfb35a1f5accf9e49d9e6a1d6ba6a2aa33c0cf43f0786db1d890",
        "F02": "662eda49e795ad974be204a46f231a9e63bedff074fff80d4c4ecec8b6f6a4a5"
    ]
    private static let steps = [("A1", "F01"), ("B", "F02"), ("A2", "F01")]

    static func execute(documents: URL, fixtureDirectory: URL, systemVersion: String) -> Int32 {
        let output = documents.appendingPathComponent("direct-vision-multi.json")
        var rows: [[String: Any]] = steps.map { ["caseID": $0.0, "inputID": $0.1,
            "inputSHA256": fixtures[$0.1]!, "phase": "unrun", "performEntryCheckpoints": 0,
            "supportDiscoveryEntryCheckpoints": 0] }
        var report: [String: Any] = [
            "schemaVersion": 1, "protocol": "direct-vision-multi-v1", "phase": "prepared",
            "executionHostKind": "nativeMacOS", "systemVersion": systemVersion,
            "orderedCaseIDs": steps.map { $0.0 }, "orderedInputIDs": steps.map { $0.1 },
            "maximumPerformCalls": 3, "maximumSupportDiscoveryCalls": 3,
            "performEntryCheckpoints": 0, "supportDiscoveryEntryCheckpoints": 0,
            "automaticRetries": 0, "caseAttemptsMaximum": 1, "plannedIdenticalRepeatIsRetry": false,
            "requestedRevision": 2, "cropAndScale": "centerCrop", "orientation": "up",
            "regionOfInterest": [0, 0, 1, 1], "workerIsMainThread": Thread.isMainThread,
            "largeLanguageModelCalls": 0, "classifierTrainingCalls": 0,
            "productionReviewStorageTouched": false, "qaEvidenceStorageWrites": true,
            "foodRecognitionAssessed": false, "MLShapedArrayEquivalenceEstablished": false,
            "causalCPUOrEspressoExplanationEstablished": false, "gateOrTrainingAdopted": false,
            "actualAppUI": false, "physicalDeviceAssessed": false,
            "networkIsolationEstablished": false, "performanceAssessed": false,
            "diagnosticCriteriaPassed": false, "cases": rows, "unrunCaseIDs": steps.map { $0.0 },
            "numericCriteria": ["expectedCount": 768, "minimumNormExclusive": 1e-8,
                "minimumSpanExclusive": 1e-6, "acrossMaxAbsMinimumInclusive": 1e-4,
                "acrossL2MinimumInclusive": 1e-3, "repeatMaxAbsMaximumInclusive": 1e-5,
                "repeatL2MaximumInclusive": 1e-4],
            "scope": "Two fixed procedural inputs and one predeclared identical repeat; diagnostic numeric conditions only"
        ]
        var activeIndex: Int?
        do {
            persist(report, output)
            guard !Thread.isMainThread else { throw Stop(reason: "workerUnexpectedlyMainThread") }
            report["phase"] = "preflightingAllFixtures"
            persist(report, output)
            // Check both frozen inputs before any request. Each case decodes its same bytes again.
            for inputID in ["F01", "F02"] {
                let url = fixtureDirectory.appendingPathComponent(inputID + ".png")
                guard FileManager.default.fileExists(atPath: url.path) else { throw Stop(reason: "fixtureMissing") }
                let data = try Data(contentsOf: url)
                guard hash(data) == fixtures[inputID], let imageSource = CGImageSourceCreateWithData(data as CFData, nil),
                      let cg = CGImageSourceCreateImageAtIndex(imageSource, 0, nil), cg.width == 360, cg.height == 360 else { throw Stop(reason: "fixturePreflightMismatch") }
            }
            report["allFixturePreflightsPassed"] = true
            var vectors: [String: [Float]] = [:]
            var metrics: [[String: Any]] = []
            for (index, step) in steps.enumerated() {
                activeIndex = index
                report["activeCaseID"] = step.0
                report["phase"] = "runningCase"
                persist(report, output)
                let values = try runCase(caseID: step.0, inputID: step.1, inputSHA: fixtures[step.1]!,
                                         documents: documents, fixtureDirectory: fixtureDirectory, systemVersion: systemVersion) { row in
                    rows[index] = row
                    report["cases"] = rows
                    report["unrunCaseIDs"] = rows.filter { $0["phase"] as? String == "unrun" }.compactMap { $0["caseID"] as? String }
                    report["performEntryCheckpoints"] = rows.reduce(0) { $0 + ($1["performEntryCheckpoints"] as? Int ?? 0) }
                    report["supportDiscoveryEntryCheckpoints"] = rows.reduce(0) { $0 + ($1["supportDiscoveryEntryCheckpoints"] as? Int ?? 0) }
                    persist(report, output)
                }
                report["phase"] = "checkingVectorMetrics"
                persist(report, output)
                guard values.count == 768, values.allSatisfy({ $0.isFinite }) else { throw NumericStop(reason: "countOrFinitenessCriterion") }
                let doubles = values.map(Double.init)
                let norm = sqrt(doubles.reduce(0) { $0 + $1 * $1 })
                let span = doubles.max()! - doubles.min()!
                let vectorOK = norm > 1e-8 && span > 1e-6
                metrics.append(["caseID": step.0, "count": values.count, "allFinite": true,
                    "norm": norm, "span": span, "passed": vectorOK])
                report["vectorMetrics"] = metrics
                persist(report, output)
                guard vectorOK else { throw NumericStop(reason: "vectorNormOrSpanCriterion") }
                vectors[step.0] = values
                if step.0 == "B" {
                    let distance = distances(vectors["A1"]!, values)
                    let passed = distance.maxAbs >= 1e-4 && distance.l2 >= 1e-3
                    report["acrossInputComparison"] = ["first": "A1", "second": "B",
                        "maxAbs": distance.maxAbs, "l2": distance.l2, "passed": passed]
                    persist(report, output)
                    guard passed else { throw NumericStop(reason: "acrossInputDifferenceCriterion") }
                } else if step.0 == "A2" {
                    let distance = distances(vectors["A1"]!, values)
                    let passed = distance.maxAbs <= 1e-5 && distance.l2 <= 1e-4
                    report["identicalInputComparison"] = ["first": "A1", "second": "A2",
                        "maxAbs": distance.maxAbs, "l2": distance.l2,
                        "binaryIdentical": hash(try Data(contentsOf: documents.appendingPathComponent("A1.bin"))) == hash(try Data(contentsOf: documents.appendingPathComponent("A2.bin"))),
                        "passed": passed]
                    persist(report, output)
                    guard passed else { throw NumericStop(reason: "identicalRepeatCriterion") }
                }
            }
            report["phase"] = "completed"
            report["diagnosticCriteriaPassed"] = true
            report["returnedCaseCount"] = vectors.count
            report["exitCode"] = 0
            persist(report, output)
            return 0 // These three diagnostic conditions only; no trained or semantic acceptance.
        } catch {
            report["failedPhase"] = report["phase"]
            report["phase"] = "capturingErrorDetails"
            let nsError = error as NSError
            report["errorType"] = String(reflecting: type(of: error))
            report["errorDomain"] = String(nsError.domain.prefix(256))
            report["errorCode"] = nsError.code
            if let stop = error as? Stop { report["localStopReason"] = stop.reason }
            if let stop = error as? NumericStop { report["localNumericCriterionFailure"] = stop.reason }
            if let index = activeIndex {
                report["failedCaseID"] = steps[index].0
                report["failedCasePhase"] = rows[index]["phase"]
            }
            persist(report, output)
            var budget = CaptureBudget()
            report["capturedNSError"] = capture(nsError, depth: 0, budget: &budget)
            report["captureLimits"] = ["maximumNestingDepth": 6, "maximumValueNodes": 64,
                "maximumDictionaryEntries": 16, "maximumArrayEntries": 8,
                "maximumCharactersPerValue": 2048, "aggregateCharacterBudget": 12000,
                "remainingCharacters": budget.characters, "remainingNodes": budget.nodes,
                "truncationCount": budget.truncations]
            report["phase"] = "stopped"
            report["unrunCaseIDs"] = rows.filter { $0["phase"] as? String == "unrun" }.compactMap { $0["caseID"] as? String }
            report["exitCode"] = 6
            persist(report, output)
            return 6
        }
    }

    private static func distances(_ first: [Float], _ second: [Float]) -> (maxAbs: Double, l2: Double) {
        let deltas = zip(first, second).map { abs(Double($0.0) - Double($0.1)) }
        return (deltas.max()!, sqrt(deltas.reduce(0) { $0 + $1 * $1 }))
    }

    private static func runCase(caseID: String, inputID: String, inputSHA: String,
        documents: URL, fixtureDirectory: URL, systemVersion: String, update: ([String: Any]) -> Void) throws -> [Float] {
        var report: [String: Any] = [
            "schemaVersion": 1, "protocol": "direct-vision-multi-v1", "phase": "prepared",
            "executionHostKind": "nativeMacOS", "systemVersion": systemVersion,
            "scope": "One fixed case in serial A1-B-A2 numerical diagnostic; no food or causal acceptance",
            "caseID": caseID,
            "inputID": inputID, "inputSHA256": inputSHA,
            "maximumPerformCalls": 1, "performEntryCheckpoints": 0, "supportDiscoveryEntryCheckpoints": 0,
            "automaticRetries": 0, "largeLanguageModelCalls": 0, "classifierTrainingCalls": 0,
            "requestedRevision": 2, "cropAndScale": "centerCrop", "regionOfInterest": [0, 0, 1, 1],
            "orientation": "up", "inputRoute": "ImageIO CGImage -> VNImageRequestHandler(cgImage:)",
            "renderingContext": "No supplied CIContext; empty handler options",
            "MLComputeAssignment": "Only request-returned typed CPU at every exposed stage; no default fallback",
            "workerIsMainThread": Thread.isMainThread, "allExposedStagesAssignedCPU": false,
            "observationReturned": false, "rawErrorDetailsLocalOnly": true,
            "productionReviewStorageTouched": false, "qaEvidenceStorageWrites": true,
            "acceptanceOrCausalComparisonAssessed": false, "foodRecognitionAssessed": false,
            "numericalViabilityPassed": false, "MLShapedArrayEquivalenceEstablished": false,
            "actualAppUI": false, "networkIsolationEstablished": false, "performanceAssessed": false,
            "entryCheckpointIsNotOSDispatchProof": true
        ]
            update(report)
            guard !Thread.isMainThread else { throw Stop(reason: "workerUnexpectedlyMainThread") }
            report["phase"] = "preflightingFixture"
            update(report)
            let url = fixtureDirectory.appendingPathComponent(inputID + ".png")
            guard FileManager.default.fileExists(atPath: url.path) else { throw Stop(reason: "fixtureMissing") }
            let data = try Data(contentsOf: url)
            guard hash(data) == inputSHA, let source = CGImageSourceCreateWithData(data as CFData, nil),
                  let cg = CGImageSourceCreateImageAtIndex(source, 0, nil), cg.width == 360, cg.height == 360 else { throw Stop(reason: "fixtureHashDecodeOrDimensions") }
            report["fixturePreflightPassed"] = true
            report["phase"] = "configuringRequest"
            update(report)
            guard VNGenerateImageFeaturePrintRequest.supportedRevisions.contains(VNGenerateImageFeaturePrintRequestRevision2) else { throw Stop(reason: "revision2NotReportedSupported") }
            let request = VNGenerateImageFeaturePrintRequest()
            request.revision = VNGenerateImageFeaturePrintRequestRevision2
            request.imageCropAndScaleOption = .centerCrop
            request.regionOfInterest = CGRect(x: 0, y: 0, width: 1, height: 1)
            report["configuredRevision"] = request.revision
            report["phase"] = "discoveringComputeSupport"
            report["supportDiscoveryEntryCheckpoints"] = 1
            update(report)
            let supported = try request.supportedComputeStageDevices
            let stages = supported.keys.sorted { $0.rawValue < $1.rawValue }
            report["stageDeviceSupport"] = stages.map { stage in
                ["stage": stage.rawValue, "devices": supported[stage, default: []].map(deviceRecord)] as [String: Any]
            }
            report["exposedStageCount"] = stages.count
            report["mainStageExposed"] = supported[.main] != nil
            report["phase"] = "checkingCPUSupport"
            update(report)
            guard supported[.main] != nil, !stages.isEmpty else { throw Stop(reason: "requiredMainStageMissing") }
            var selections: [(VNComputeStage, MLComputeDevice)] = []
            for stage in stages {
                guard let cpu = supported[stage, default: []].first(where: isCPU) else {
                    report["CPUUnsupportedStage"] = stage.rawValue
                    throw Stop(reason: "CPUNotReturnedForExposedStage")
                }
                selections.append((stage, cpu))
            }
            report["allExposedStagesReportedCPU"] = true
            report["phase"] = "assigningCPUDevices"
            update(report)
            var assigned: [[String: Any]] = []
            for (stage, cpu) in selections {
                request.setComputeDevice(cpu, for: stage)
                let readback = request.computeDevice(for: stage)
                let matches = readback == cpu && readback.map(isCPU) == true
                assigned.append(["stage": stage.rawValue, "selected": deviceRecord(cpu),
                                 "readback": readback.map(deviceRecord) ?? ["kind": "nil"],
                                 "readbackMatchesReturnedCPU": matches])
                report["selectedDevices"] = assigned
                update(report)
                guard matches else { throw Stop(reason: "CPUAssignmentReadbackMismatch") }
            }
            guard request.revision == 2, request.imageCropAndScaleOption == .centerCrop,
                  request.regionOfInterest == CGRect(x: 0, y: 0, width: 1, height: 1),
                  selections.allSatisfy({ stage, cpu in request.computeDevice(for: stage) == cpu }) else { throw Stop(reason: "configurationChangedBeforePerform") }
            report["allExposedStagesAssignedCPU"] = true
            report["phase"] = "performingRequest"
            report["performEntryCheckpoints"] = 1
            update(report)
            // Sole perform. Mutable request/handler and decoded CGImage never leave this worker.
            let handler = VNImageRequestHandler(cgImage: cg, orientation: .up, options: [:])
            try handler.perform([request])
            report["performReturnedSuccessfully"] = true
            report["phase"] = "inspectingObservation"
            let observations = request.results ?? []
            report["observationCount"] = observations.count
            update(report)
            guard observations.count == 1, let observation = observations.first else { throw Stop(reason: "expectedExactlyOneObservation") }
            report["observationReturned"] = true
            report["observationRevision"] = observation.requestRevision
            report["elementTypeRawValue"] = observation.elementType.rawValue
            report["elementCount"] = observation.elementCount
            let bytes = observation.data
            report["observationDataBytes"] = bytes.count
            report["observationDataSHA256"] = hash(bytes)
            report["matchesDocumentedComponentV2Count"] = observation.elementCount == 768
            update(report)
            guard bytes.count <= 1048576 else { throw Stop(reason: "observationDataExceedsDiagnosticStorageBound") }
            let binaryURL = documents.appendingPathComponent(caseID + ".bin")
            try bytes.write(to: binaryURL, options: .withoutOverwriting)
            guard try Data(contentsOf: binaryURL) == bytes else { throw Stop(reason: "observationDataReadbackMismatch") }
            report["observationDataSaved"] = true
            // The new protocol freezes exact revision/type/count before any requests.
            let count = observation.elementCount
            guard observation.requestRevision == 2, observation.elementType == .float,
                  count == 768, bytes.count == 768 * MemoryLayout<Float>.stride else {
                throw Stop(reason: "unexpectedRevisionTypeCountOrBytes")
            }
            let values: [Float] = bytes.withUnsafeBytes { raw in
                (0..<count).map { raw.loadUnaligned(fromByteOffset: $0 * MemoryLayout<Float>.stride, as: Float.self) }
            }
            let finite = values.allSatisfy { $0.isFinite }
            report["scalars"] = values.map { $0.isFinite ? ($0 as Any) : String(describing: $0) }
            report["allScalarsFinite"] = finite
            report["nonconstantWithinVector"] = finite ? (values.dropFirst().contains { $0 != values[0] } as Any) : NSNull()
            report["scalarAnalysisComplete"] = true
            report["scalarEncoding"] = "Native Float32 decoded with unaligned loads; nonfinite values represented as text, exact bytes retained"
            report["phase"] = "observationReturned"
            report["exitCode"] = 0
            update(report)
            return values
    }

    private static func isCPU(_ device: MLComputeDevice) -> Bool {
        if case .cpu = device { return true }
        return false
    }

    private static func deviceRecord(_ device: MLComputeDevice) -> [String: Any] {
        switch device {
        case .cpu(let value): return ["kind": "cpu", "type": String(reflecting: type(of: value))]
        case .gpu(let value): return ["kind": "gpu", "type": String(reflecting: type(of: value))]
        case .neuralEngine(let value): return ["kind": "neuralEngine", "type": String(reflecting: type(of: value))]
        @unknown default: return ["kind": "unknown", "type": String(reflecting: type(of: device))]
        }
    }

    private static func hash(_ data: Data) -> String {
        SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
    }

    private struct CaptureBudget {
        var characters = 12000
        var nodes = 64
        var truncations = 0
        var seen = Set<ObjectIdentifier>()
    }

    private static func text(_ value: String, limit: Int = 2048, budget: inout CaptureBudget) -> String {
        let result = String(value.prefix(max(0, min(limit, budget.characters))))
        if result.count < value.count { budget.truncations += 1 }
        budget.characters -= result.count
        return result
    }

    private static func capture(_ error: NSError, depth: Int, budget: inout CaptureBudget) -> [String: Any] {
        guard depth <= 6, budget.nodes > 0 else { budget.truncations += 1; return ["truncated": "depthOrNodeLimit"] }
        let identity = ObjectIdentifier(error)
        guard budget.seen.insert(identity).inserted else { budget.truncations += 1; return ["truncated": "alreadyCapturedError"] }
        budget.nodes -= 1
        var result: [String: Any] = ["domain": text(error.domain, limit: 256, budget: &budget), "code": error.code]
        // Prioritize underlying/userInfo causes before potentially verbose descriptions.
        result["userInfo"] = dictionary(error.userInfo, depth: depth + 1, budget: &budget)
        result["description"] = text(error.description, budget: &budget)
        result["localizedDescription"] = text(error.localizedDescription, budget: &budget)
        if let reason = error.localizedFailureReason { result["localizedFailureReason"] = text(reason, budget: &budget) }
        if let suggestion = error.localizedRecoverySuggestion { result["localizedRecoverySuggestion"] = text(suggestion, budget: &budget) }
        return result
    }

    private static func dictionary(_ info: [String: Any], depth: Int, budget: inout CaptureBudget) -> [String: Any] {
        guard depth <= 6, budget.nodes > 0 else { budget.truncations += 1; return ["truncated": "depthOrNodeLimit"] }
        let priority = ["NSUnderlyingError", "NSMultipleUnderlyingErrors", "NSDebugDescription", "NSLocalizedDescription",
                        "NSLocalizedFailureReason", "NSLocalizedRecoverySuggestion"]
        let keys = priority.filter { info[$0] != nil } + info.keys.filter { !priority.contains($0) }.sorted()
        var result: [String: Any] = [:]
        for key in keys.prefix(16) {
            if budget.characters == 0 || budget.nodes == 0 { result["truncated"] = "characterOrNodeLimit"; budget.truncations += 1; break }
            let savedKey = text(key, limit: 128, budget: &budget)
            result[savedKey] = value(info[key]!, depth: depth, budget: &budget)
        }
        if keys.count > 16 { result["omittedEntryCount"] = keys.count - 16; budget.truncations += 1 }
        return result
    }

    private static func value(_ object: Any, depth: Int, budget: inout CaptureBudget) -> Any {
        guard depth <= 6, budget.nodes > 0 else { budget.truncations += 1; return ["truncated": "depthOrNodeLimit"] }
        if let error = object as? NSError { return capture(error, depth: depth, budget: &budget) }
        budget.nodes -= 1
        if let string = object as? String { return text(string, budget: &budget) }
        if let url = object as? URL { return ["url": text(url.absoluteString, budget: &budget)] }
        if let number = object as? NSNumber {
            if number.doubleValue.isFinite { return number }
            return ["nonfiniteNumber": text(number.stringValue, budget: &budget)]
        }
        if object is NSNull { return NSNull() }
        if let data = object as? Data { return ["type": "Data", "byteCount": data.count] }
        if let info = object as? [String: Any] { return dictionary(info, depth: depth + 1, budget: &budget) }
        if let array = object as? [Any] {
            if array.count > 8 { budget.truncations += 1 }
            return ["items": array.prefix(8).map { value($0, depth: depth + 1, budget: &budget) },
                    "omittedEntryCount": max(0, array.count - 8)]
        }
        return ["typeOnly": text(String(reflecting: type(of: object)), limit: 256, budget: &budget)]
    }

    static func persist(_ report: [String: Any], _ url: URL) {
        do {
            let data = try JSONSerialization.data(withJSONObject: report, options: [.prettyPrinted, .sortedKeys])
            try data.write(to: url, options: .atomic)
            guard try Data(contentsOf: url) == data else { _exit(5) }
        } catch { _exit(5) }
    }

    private struct Stop: Error { let reason: String }
    private struct NumericStop: Error { let reason: String }
}
