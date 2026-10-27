import Foundation
import XCTest
final class MealMirrorUITests:XCTestCase {
 @MainActor func testExact26PhotoLabelSaveRelaunchDelete() throws {
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
  print("MM_IOS27_EXACT26_FULL_ANALYSIS_CONTEXT_BEGIN\n\(app.debugDescription)\nMM_IOS27_EXACT26_FULL_ANALYSIS_CONTEXT_END")
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
  let item="QA exact26 checked item 20261027 F1"
  // Model clues remain tentative; this separate label-entry route starts blank.
  tap(app.buttons["carbin.estimate.addAmount"],in:app)
  let name=app.textFields["carbin.ingredient.name"]
  let grams=app.textFields["carbin.ingredient.grams"]
  let add=app.buttons["carbin.ingredient.confirm"]
  XCTAssertTrue(name.waitForExistence(timeout:10) && grams.exists && add.exists)
  XCTAssertFalse(add.isEnabled)
  let v=grams.value as? String
  XCTAssertTrue(v == nil || v == "" || v == grams.placeholderValue,"No actual grams may prefill from image/OCR")
  let n=name.value as? String
  XCTAssertTrue(n == nil || n == "" || n == name.placeholderValue)
  tap(name,in:app);name.typeText(item)
  XCTAssertEqual(name.value as? String,item)
  snapshot(app,"08-editable-name-empty-grams-disabled-Add")
  tap(grams,in:app);grams.typeText("37")
  let enabled=XCTNSPredicateExpectation(predicate:NSPredicate(format:"enabled == true"),object:add)
  XCTAssertEqual(XCTWaiter.wait(for:[enabled],timeout:5),.completed)
  snapshot(app,"09-separately-typed-synthetic37")
  tap(add,in:app)
  let dismissed=XCTNSPredicateExpectation(predicate:NSPredicate(format:"exists == false"),object:name)
  XCTAssertEqual(XCTWaiter.wait(for:[dismissed],timeout:10),.completed)
  XCTAssertTrue(app.descendants(matching:.any).matching(NSPredicate(format:"label CONTAINS %@ AND label CONTAINS %@ AND label CONTAINS %@",item,"Your entry","37 g")).count>0)
  let review=app.buttons["carbin.estimate.review"]
  XCTAssertTrue(review.exists && !review.isEnabled)
  snapshot(app,"10-manual-amount-before-separate-parts-confirmation")
  tap(app.switches["carbin.estimate.confirmParts"],in:app)
  XCTAssertTrue(review.isEnabled)
  tap(review,in:app)
  XCTAssertTrue(app.buttons["carbin.review.save"].waitForExistence(timeout:10))
  XCTAssertTrue(app.staticTexts["37 g carbohydrates"].exists)
  XCTAssertTrue(app.staticTexts["Included components"].exists)
  snapshot(app,"11-final-Review-before-one-Save")
  let save=app.buttons["carbin.review.save"]
  tap(save,in:app)
  XCTAssertTrue(app.buttons["carbin.review.another"].waitForExistence(timeout:10))
  XCTAssertFalse(save.exists)
  XCTAssertTrue(app.staticTexts.matching(NSPredicate(format:"label CONTAINS %@","Your selected photos were not copied into history.")).firstMatch.exists)
  snapshot(app,"12-one-local-record-saved")
  app.terminate();app.launch()
  openHistory(app,expectedCount:1)
  let rows=app.staticTexts.matching(NSPredicate(format:"identifier BEGINSWITH %@","carbin.history.item."))
  XCTAssertEqual(rows.count,1)
  XCTAssertEqual(app.staticTexts["carbin.history.item.0"].label,"Your meal review")
  snapshot(app,"13-relaunched-one-photo-record")
  tap(app.buttons["carbin.history.open.0"],in:app)
  XCTAssertTrue(app.navigationBars["Saved review"].waitForExistence(timeout:10))
  XCTAssertTrue(app.staticTexts.matching(NSPredicate(format:"label == %@","Your meal review")).firstMatch.exists)
  XCTAssertTrue(app.staticTexts.matching(NSPredicate(format:"label == %@","Your on-device photo")).firstMatch.exists)
  let checked=app.descendants(matching:.any).matching(NSPredicate(format:"label CONTAINS %@ AND label CONTAINS %@ AND label CONTAINS %@",item,"37 g","Your entry"))
  XCTAssertTrue(checked.firstMatch.exists)
  snapshot(app,"14-unique-QA-item-photo-detail")
  // Empty host baseline + one saved row + exact QA item/source/amount guard.
  let delete=app.buttons["carbin.history.detail.delete"]
  tap(delete,in:app)
  let alert=app.alerts["Delete this saved review?"]
  XCTAssertTrue(alert.waitForExistence(timeout:10))
  let confirms=alert.buttons.matching(identifier:"carbin.history.detail.delete.confirm")
  XCTAssertTrue((1...3).contains(confirms.count))
  let aliases=confirms.allElementsBoundByIndex
  let frame=aliases[0].frame
  for alias in aliases {
   XCTAssertEqual(alias.label,"Delete review")
   XCTAssertEqual(alias.frame,frame)
   XCTAssertTrue(alias.isEnabled && alias.isHittable)
  }
  XCTAssertTrue(app.frame.contains(frame) && frame.width>0 && frame.height>0)
  print("MM_GUARDED_QA_DELETE aliases=\(aliases.count) frame=\(frame)")
  snapshot(app,"15-one-confirmation-action-aliases")
  confirms.firstMatch.tap()
  let deleteDismissed=XCTNSPredicateExpectation(predicate:NSPredicate(format:"exists == false"),object:delete)
  XCTAssertEqual(XCTWaiter.wait(for:[deleteDismissed],timeout:10),.completed)
  XCTAssertTrue(app.staticTexts["No saved reviews yet"].waitForExistence(timeout:10))
  XCTAssertEqual(rows.count,0)
  XCTAssertTrue(app.buttons["carbin.history.deleteAll"].exists && !app.buttons["carbin.history.deleteAll"].isEnabled)
  snapshot(app,"16-empty-after-QA-delete")
  app.terminate();app.launch()
  openHistory(app,expectedCount:0)
  XCTAssertEqual(rows.count,0)
  snapshot(app,"17-relaunched-empty-history")
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
