import Foundation
import XCTest
final class MealMirrorUITests:XCTestCase {
 @MainActor func testExact25LabelSettledAndSettings() throws {
  continueAfterFailure=false
  let app=XCUIApplication(bundleIdentifier:"com.mealmirror.swiftchallenge")
  app.launchArguments=["-carbin.onboarding.completed", "YES"];app.launchEnvironment=[:];app.launch()
  defer { snapshot(app,"99-final");app.terminate() }
  XCTAssertTrue(app.buttons["carbin.home.library"].waitForExistence(timeout:25))
  tap(app.buttons["carbin.home.library"],in:app)
  XCTAssertTrue(app.navigationBars["Photos"].waitForExistence(timeout:20))
  let meal=app.images.matching(NSPredicate(format:"label == %@","Photo, October 01, 4:51 AM"))
  XCTAssertEqual(meal.count,1)
  XCTAssertTrue(app.frame.contains(meal.firstMatch.frame) && meal.firstMatch.isHittable)
  snapshot(app,"01-observed-meal-before-selection")
  meal.firstMatch.coordinate(withNormalizedOffset:CGVector(dx:0.5,dy:0.5)).tap()
  let done=app.buttons.matching(NSPredicate(format:"label == %@","Done"))
  XCTAssertEqual(done.count,1);XCTAssertTrue(done.firstMatch.isEnabled && done.firstMatch.isHittable)
  done.firstMatch.tap()
  XCTAssertTrue(app.descendants(matching:.any).matching(NSPredicate(format:"label == %@","Selected meal photo 1")).firstMatch.waitForExistence(timeout:30))
  snapshot(app,"02-meal-attached")
  tap(app.buttons["carbin.meal.labelLibrary"],in:app)
  XCTAssertTrue(app.navigationBars["Photos"].waitForExistence(timeout:20))
  let label=app.images.matching(NSPredicate(format:"label == %@","Photo, October 27, 6:15 AM"))
  XCTAssertEqual(label.count,1)
  XCTAssertTrue(app.frame.contains(label.firstMatch.frame) && label.firstMatch.isHittable)
  snapshot(app,"03-observed-label-before-selection")
  label.firstMatch.coordinate(withNormalizedOffset:CGVector(dx:0.5,dy:0.5)).tap()
  XCTAssertTrue(app.descendants(matching:.any).matching(NSPredicate(format:"label == %@","Selected nutrition label photo")).firstMatch.waitForExistence(timeout:30))
  XCTAssertFalse(app.navigationBars["Photos"].exists)
  snapshot(app,"04-meal-and-separate-label-description-blank")
  print("MM_IOS27_EXACT25_FULL_ANALYSIS_CONTEXT_BEGIN\n\(app.debugDescription)\nMM_IOS27_EXACT25_FULL_ANALYSIS_CONTEXT_END")
  tap(app.buttons["carbin.meal.analyze"],in:app)
  XCTAssertTrue(app.navigationBars["Your estimate"].waitForExistence(timeout:60))
  XCTAssertTrue(app.staticTexts["No reliable range yet"].exists)
  XCTAssertFalse(app.buttons["carbin.estimate.review"].exists)
  snapshot(app,"05-no-automatic-carbohydrates")
  let trail=app.buttons.matching(NSPredicate(format:"label == %@","Review trail"))
  XCTAssertEqual(trail.count,1)
  tap(trail.firstMatch,in:app)
  snapshot(app,"06-expanded-actual-model-status")
  let successNames="Apple Intelligence on this device. Food names only. Check each name against your photo; no carbohydrate amount comes from these clues."
  let successEmpty="Apple Intelligence on this device. No clear food clues found in this photo."
  let namesStatus=app.staticTexts.matching(NSPredicate(format:"label == %@",successNames)).firstMatch.exists
  let emptyStatus=app.staticTexts.matching(NSPredicate(format:"label == %@",successEmpty)).firstMatch.exists
  print("MM_IOS27_MODEL_OUTCOME namesStatus=\(namesStatus) emptyStatus=\(emptyStatus)")
  XCTAssertFalse(namesStatus && emptyStatus)
  XCTAssertTrue(namesStatus || emptyStatus,"This full case requires an actual inspected local-model outcome, not an unavailable fallback.")
  let clues=app.buttons.matching(identifier:"carbin.estimate.photoNameClues")
  if namesStatus { XCTAssertTrue((1...6).contains(clues.count)) }
  if emptyStatus { XCTAssertEqual(clues.count,0) }
  let ocr=app.descendants(matching:.any).matching(identifier:"carbin.estimate.labelText")
  XCTAssertEqual(ocr.count,1)
  tap(ocr.firstMatch,in:app)
  XCTAssertTrue(app.staticTexts.matching(NSPredicate(format:"label CONTAINS %@ AND label CONTAINS %@","Carbohydrate","37")).count>0)
  snapshot(app,"07-actual-label-transcription-not-amount")
  XCTAssertTrue(app.staticTexts["No reliable range yet"].exists)
  let serving=app.staticTexts.matching(NSPredicate(format:"label == %@","per serving")).firstMatch
  XCTAssertTrue(serving.waitForExistence(timeout:5))
  XCTAssertTrue(serving.isHittable)
  snapshot(app,"08-label-settled-first")
  let firstFrame=serving.frame
  print("MM_SETTLED_SERVING_FIRST \(firstFrame)")
  // A second fresh AX observation distinguishes a settled disclosure from its opening frame.
  print("MM_SETTLED_LABEL_TREE \(app.debugDescription)")
  XCTAssertEqual(serving.frame,firstFrame)
  snapshot(app,"09-label-settled-second")
  app.terminate();app.launch()
  tap(app.buttons["carbin.home.settings"],in:app)
  XCTAssertTrue(app.navigationBars["Settings"].waitForExistence(timeout:10))
  XCTAssertTrue(app.buttons["carbin.settings.language"].exists)
  snapshot(app,"10-settings-single-heading")
 }

 @MainActor private func openHistory(_ app:XCUIApplication,expectedCount:Int) {
  let controls=app.buttons.matching(identifier:"carbin.home.history")
  XCTAssertTrue(controls.firstMatch.waitForExistence(timeout:20));XCTAssertEqual(controls.count,1)
  tap(controls.firstMatch,in:app)
  if expectedCount == 0 {XCTAssertTrue(app.staticTexts["No saved reviews yet"].waitForExistence(timeout:10))}
  else {XCTAssertTrue(app.staticTexts["carbin.history.item.0"].waitForExistence(timeout:10))}
  let rows=app.staticTexts.matching(NSPredicate(format:"identifier BEGINSWITH %@","carbin.history.item."))
  XCTAssertEqual(rows.count,expectedCount)
  if expectedCount == 0 {XCTAssertTrue(app.buttons["carbin.history.deleteAll"].exists && !app.buttons["carbin.history.deleteAll"].isEnabled)}
 }
    @MainActor private func isExposed(_ element: XCUIElement, in app: XCUIApplication) -> Bool {
        guard element.exists && element.isHittable else { return false }
        let frame = element.frame
        let viewport = app.frame
        guard frame.minX.isFinite && frame.minY.isFinite && frame.width.isFinite && frame.height.isFinite,
              frame.width > 0 && frame.height > 0 && viewport.contains(frame) else { return false }
        let pinnedIDs = ["carbin.home.estimate", "carbin.meal.analyze", "carbin.estimate.addAmount", "carbin.estimate.review", "carbin.estimate.reviewCandidates"]
        for id in pinnedIDs where element.identifier != id {
            let pinned = app.buttons[id]
            if pinned.exists && pinned.frame.intersects(frame) { return false }
        }
        return true
    }
    @MainActor
    private func reveal(_ element: XCUIElement, in app: XCUIApplication) {
        XCTAssertTrue(element.exists)
        for step in 0..<12 {
            if isExposed(element, in: app) { break }
            let scroll = app.scrollViews.firstMatch
            XCTAssertTrue(scroll.exists)
            let frame = element.frame
            XCTAssertTrue(frame.minX.isFinite && frame.minY.isFinite && frame.width > 0 && frame.height > 0, "Invalid offscreen frame; do not guess a scroll direction.")
            let bounds = scroll.frame.intersection(app.frame)
            var bottom = bounds.maxY - 20
            var x = bounds.midX
            for id in ["carbin.home.estimate", "carbin.meal.analyze", "carbin.estimate.addAmount", "carbin.estimate.review", "carbin.estimate.reviewCandidates"] where element.identifier != id {
                let pinned = app.buttons[id]
                if pinned.exists && pinned.isHittable {
                    bottom = min(bottom, pinned.frame.minY - 12)
                    x = pinned.frame.midX
                }
            }
            let top = bounds.minY + 40
            XCTAssertGreaterThan(bottom - top, 160)
            let mid = (top + bottom) / 2
            let distance = min(120.0, (bottom - top) / 3)
            let goesUp = frame.maxY > bottom
            XCTAssertTrue(goesUp || frame.minY < top, "Target is inside safe viewport but not hittable; investigate instead of blind scrolling.")
            let startY = goesUp ? mid + distance / 2 : mid - distance / 2
            let endY = goesUp ? mid - distance / 2 : mid + distance / 2
            XCTAssertTrue(bounds.contains(CGPoint(x: x, y: startY)) && bounds.contains(CGPoint(x: x, y: endY)))
            print("MM_BOUNDED_SCROLL step=\(step) target=\(element.identifier) frame=\(frame) start=(\(x),\(startY)) end=(\(x),\(endY))")
            let origin = scroll.coordinate(withNormalizedOffset: .zero)
            origin.withOffset(CGVector(dx: x - bounds.minX, dy: startY - bounds.minY))
                .press(forDuration: 0.05, thenDragTo: origin.withOffset(CGVector(dx: x - bounds.minX, dy: endY - bounds.minY)))
        }
        XCTAssertTrue(isExposed(element, in: app), "Target must be wholly visible and clear of another pinned action.")
    }

    @MainActor private func tap(_ element: XCUIElement, in app: XCUIApplication) {
        reveal(element, in: app); XCTAssertTrue(element.isEnabled)
        print("MM_VISIBLE_CONTROL id=\(element.identifier) frame=\(element.frame)")
        if element.identifier == "carbin.meal.labelLibrary" { snapshot(app, "03b-label-control-clear-of-pinned-action") }
        element.tap()
    }
    @MainActor private func snapshot(_ app: XCUIApplication, _ name: String) {
        let pixels = XCTAttachment(screenshot: app.screenshot()); pixels.name = name; pixels.lifetime = .keepAlways; add(pixels)
        let tree = XCTAttachment(string: app.debugDescription); tree.name = name + "-hierarchy"; tree.lifetime = .keepAlways; add(tree)
        print("MM_PHOTO_LABEL_QA \(name)\n\(app.debugDescription)")
    }
}
