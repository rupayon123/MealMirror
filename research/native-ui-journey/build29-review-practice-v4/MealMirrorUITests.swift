import Foundation
import XCTest
final class MealMirrorUITests:XCTestCase {
 @MainActor func testExact29PracticeReviewSource() throws {
  continueAfterFailure=false
  let app=XCUIApplication(bundleIdentifier:"com.mealmirror.swiftchallenge")
  app.launchArguments=["-carbin.onboarding.completed","YES"];app.launchEnvironment=[:];app.launch()
  defer { snapshot(app,"99-practice-final");app.terminate() }
  XCTAssertTrue(app.buttons["carbin.home.estimate"].waitForExistence(timeout:25))
  tap(app.buttons["carbin.home.estimate"],in:app)
  XCTAssertTrue(app.navigationBars["Add a meal"].waitForExistence(timeout:20))
  snapshot(app,"00-add-meal-before-description")
  tap(app.buttons["Description"],in:app)
  snapshot(app,"00-description-before-practice")
  tap(app.buttons["carbin.practice.biryani"],in:app)
  XCTAssertTrue(app.navigationBars["Your estimate"].waitForExistence(timeout:20))
  snapshot(app,"00-practice-selected-estimate")
  let review=app.buttons["carbin.estimate.review"]
  XCTAssertTrue(review.waitForExistence(timeout:30));XCTAssertFalse(review.isEnabled)
  tap(app.switches["carbin.estimate.confirmParts"],in:app)
  XCTAssertTrue(review.isEnabled);tap(review,in:app)
  XCTAssertTrue(app.buttons["carbin.review.save"].waitForExistence(timeout:10))
  XCTAssertFalse(app.images["Selected meal photo"].exists)
  snapshot(app,"01-practice-review-opening")
  let items=app.staticTexts["Meal items"]
  reveal(items,in:app)
  XCTAssertTrue(items.exists)
  snapshot(app,"02-practice-items-heading")
  let origins=app.descendants(matching:.any).matching(NSPredicate(format:"label CONTAINS %@","Practice meal · "))
  XCTAssertGreaterThan(origins.count,0)
  reveal(origins.firstMatch,in:app)
  snapshot(app,"03-practice-item-source")
  XCTAssertTrue(app.buttons["carbin.review.save"].exists)
 }
 @MainActor private func inspectLabel(_ app:XCUIApplication,wide:Bool,prefix:String) {
  let close=app.buttons["carbin.labelViewer.close"]
  XCTAssertTrue(close.waitForExistence(timeout:10))
  let scroll=app.scrollViews["carbin.labelViewer.image"]
  XCTAssertTrue(scroll.exists)
  let smaller=app.buttons["carbin.labelViewer.smaller"]
  let larger=app.buttons["carbin.labelViewer.larger"]
  XCTAssertTrue(smaller.exists && larger.exists)
  XCTAssertFalse(smaller.isEnabled);XCTAssertTrue(larger.isEnabled)
  snapshot(app,prefix+"-fit1x")
  scroll.pinch(withScale:2,velocity:1)
  XCTAssertTrue(smaller.isEnabled && close.exists)
  snapshot(app,prefix+"-pinch-enlarged")
  for _ in 0..<6 { if smaller.isEnabled {tap(smaller,in:app)} }
  XCTAssertFalse(smaller.isEnabled)
  for _ in 0..<6 {tap(larger,in:app)}
  XCTAssertFalse(larger.isEnabled);XCTAssertTrue(smaller.isEnabled)
  snapshot(app,prefix+"-zoom4x")
  let area=scroll.frame.intersection(app.frame)
  XCTAssertGreaterThan(area.width,180);XCTAssertGreaterThan(area.height,180)
  let origin=scroll.coordinate(withNormalizedOffset:.zero)
  let start=wide ? CGPoint(x:area.midX+60,y:area.midY) : CGPoint(x:area.midX,y:area.midY+60)
  let end=wide ? CGPoint(x:area.midX-60,y:area.midY) : CGPoint(x:area.midX,y:area.midY-60)
  XCTAssertTrue(area.contains(start) && area.contains(end))
  origin.withOffset(CGVector(dx:start.x-scroll.frame.minX,dy:start.y-scroll.frame.minY)).press(forDuration:0.1,thenDragTo:origin.withOffset(CGVector(dx:end.x-scroll.frame.minX,dy:end.y-scroll.frame.minY)))
  snapshot(app,prefix+"-panned4x")
  XCTAssertTrue(close.exists && close.isHittable && app.frame.contains(close.frame),"Close must remain exposed after pan")
  for _ in 0..<6 {tap(smaller,in:app)}
  XCTAssertFalse(smaller.isEnabled);XCTAssertTrue(larger.isEnabled)
  snapshot(app,prefix+"-returned1x")
  tap(close,in:app)
  let gone=XCTNSPredicateExpectation(predicate:NSPredicate(format:"exists == false"),object:close)
  XCTAssertEqual(XCTWaiter.wait(for:[gone],timeout:10),.completed)
 }
 @MainActor private func pickImage(_ image:XCUIElement,in app:XCUIApplication,multiple:Bool) {
  let bounds=image.frame;var left=bounds.minX+8;var right=bounds.maxX-8
  for title in ["Cancel","Done","Search","Sort and Filter"] {
   for control in app.buttons.matching(NSPredicate(format:"label == %@",title)).allElementsBoundByIndex where control.isHittable && control.frame.intersects(bounds) {
    if control.frame.midX>bounds.midX {right=min(right,control.frame.minX-12)} else {left=max(left,control.frame.maxX+12)}
   }
  }
  XCTAssertGreaterThan(right-left,20);let point=CGPoint(x:(left+right)/2,y:bounds.midY)
  XCTAssertTrue(bounds.contains(point) && app.frame.contains(point));XCTAssertFalse(image.isSelected)
  image.coordinate(withNormalizedOffset:.zero).withOffset(CGVector(dx:point.x-bounds.minX,dy:point.y-bounds.minY)).tap()
  if multiple {let e=XCTNSPredicateExpectation(predicate:NSPredicate(format:"selected == true"),object:image);XCTAssertEqual(XCTWaiter.wait(for:[e],timeout:5),.completed)}
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
            if pinned.exists && pinned.frame.intersects(frame) {
                let blocks = pinned.isHittable
                print("MM_PINNED_EXPOSURE target=\(element.identifier) targetHittable=\(element.isHittable) pinned=\(id) pinnedHittable=\(blocks)")
                if blocks { return false }
            }
        }
        return true
    }
    @MainActor
    private func reveal(_ element: XCUIElement, in app: XCUIApplication) {
        XCTAssertTrue(element.exists)
        for step in 0..<30 {
            if isExposed(element, in: app) { break }
            let scroll = app.scrollViews.firstMatch
            XCTAssertTrue(scroll.exists)
            let frame = element.frame
            XCTAssertTrue(frame.minX.isFinite && frame.minY.isFinite && frame.width > 0 && frame.height > 0, "Invalid offscreen frame; do not guess a scroll direction.")
            let bounds = scroll.frame.intersection(app.frame)
            var top = bounds.minY + 40
            var bottom = bounds.maxY - 20
            var x = bounds.midX
            for id in ["carbin.home.estimate", "carbin.meal.analyze", "carbin.estimate.addAmount", "carbin.estimate.review", "carbin.estimate.reviewCandidates"] where element.identifier != id {
                let pinned = app.buttons[id]
                if pinned.exists && pinned.isHittable {
                    let visible = pinned.frame.intersection(bounds)
                    print("MM_PINNED_FRAME id=\(id) frame=\(pinned.frame) bounds=\(bounds) visible=\(visible)")
                    if !visible.isNull && visible.width > 0 && visible.height > 0 {
                        if visible.midY > bounds.midY { bottom = min(bottom, visible.minY - 12) }
                        else { top = max(top, visible.maxY + 12) }
                    }
                }
            }
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
