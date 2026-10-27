import Foundation
import XCTest
final class MealMirrorUITests:XCTestCase {
 @MainActor func testExact27PhotoRoleStatesAXDark() throws {
  continueAfterFailure=false
  let app=XCUIApplication(bundleIdentifier:"com.mealmirror.swiftchallenge")
  app.launchArguments=["-carbin.onboarding.completed","YES"];app.launch()
  defer { snapshot(app,"99-final");app.terminate() }
  tap(app.buttons["carbin.home.library"],in:app)
  XCTAssertTrue(app.navigationBars["Photos"].waitForExistence(timeout:20))
  let cancel=app.buttons.matching(NSPredicate(format:"label == %@","Cancel"));XCTAssertEqual(cancel.count,1);cancel.firstMatch.tap()
  XCTAssertTrue(app.staticTexts["No photo selected"].waitForExistence(timeout:10))
  XCTAssertFalse(app.buttons["carbin.meal.analyze"].isEnabled)
  snapshot(app,"01-empty-after-picker-cancel")
  tap(app.buttons["carbin.meal.labelLibrary"],in:app)
  choose(["Photo, October 27, 6:15 AM"],in:app,multiple:false)
  let label=role("Selected nutrition label photo",in:app)
  XCTAssertTrue(label.waitForExistence(timeout:20))
  XCTAssertTrue(app.staticTexts["No photo selected"].exists)
  XCTAssertFalse(role("Selected meal photo 1",in:app).exists)
  XCTAssertFalse(app.buttons["carbin.meal.analyze"].isEnabled)
  XCTAssertTrue(app.staticTexts["Add a meal photo too. The label can help you check a value, but it does not show the whole meal."].exists)
  snapshot(app,"02-label-only-no-food-no-analysis")
  let removeLabel=label.buttons.matching(NSPredicate(format:"identifier BEGINSWITH %@","carbin.meal.removePhoto."));XCTAssertEqual(removeLabel.count,1)
  tap(removeLabel.firstMatch,in:app)
  XCTAssertFalse(label.exists);XCTAssertTrue(app.buttons["carbin.meal.labelLibrary"].exists)
  tap(app.buttons["carbin.meal.library"],in:app)
  choose(["Photo, October 01, 4:51 AM"],in:app,multiple:true)
  let food=role("Selected meal photo 1",in:app);XCTAssertTrue(food.waitForExistence(timeout:20))
  XCTAssertFalse(label.exists);XCTAssertTrue(app.buttons["carbin.meal.analyze"].isEnabled)
  snapshot(app,"03-food-only")
  tap(app.buttons["carbin.meal.labelLibrary"],in:app)
  choose(["Photo, October 27, 6:15 AM"],in:app,multiple:false)
  XCTAssertTrue(label.waitForExistence(timeout:20));XCTAssertTrue(food.exists)
  XCTAssertLessThan(food.frame.minY,label.frame.minY)
  snapshot(app,"04-food-above-separate-label")
  let removeFood=food.buttons.matching(NSPredicate(format:"identifier BEGINSWITH %@","carbin.meal.removePhoto."));XCTAssertEqual(removeFood.count,1)
  tap(removeFood.firstMatch,in:app)
  XCTAssertFalse(food.exists);XCTAssertTrue(label.exists);XCTAssertFalse(app.buttons["carbin.meal.analyze"].isEnabled)
  tap(app.buttons["carbin.meal.library"],in:app)
  choose(["Photo, October 01, 4:51 AM","Photo, March 30, 2018, 3:14 PM","Photo, August 08, 2012, 5:55 PM"],in:app,multiple:true)
  XCTAssertTrue(role("Selected meal photo 3",in:app).waitForExistence(timeout:30))
  XCTAssertTrue(role("Selected meal photo 2",in:app).exists && label.exists)
  XCTAssertFalse(app.buttons["carbin.meal.library"].isEnabled)
  XCTAssertTrue(app.buttons["carbin.meal.analyze"].isEnabled)
  snapshot(app,"05-three-layout-fixtures-and-separate-label")
 }
 @MainActor private func role(_ label:String,in app:XCUIApplication)->XCUIElement {
  app.descendants(matching:.any).matching(NSPredicate(format:"label == %@",label)).firstMatch
 }
 @MainActor private func choose(_ labels:[String],in app:XCUIApplication,multiple:Bool) {
  XCTAssertTrue(app.navigationBars["Photos"].waitForExistence(timeout:20))
  if app.staticTexts["Private Access to Photos"].firstMatch.exists {
   snapshot(app,"picker-system-privacy-explanation")
   let close=app.buttons.matching(NSPredicate(format:"label == %@","Close"))
   XCTAssertTrue((1...3).contains(close.count))
   let aliases=close.allElementsBoundByIndex;let frame=aliases[0].frame
   for alias in aliases {XCTAssertEqual(alias.frame,frame);XCTAssertTrue(alias.isHittable && alias.isEnabled)}
   XCTAssertTrue(app.frame.contains(frame) && frame.width>0 && frame.height>0)
   close.firstMatch.tap()
  }
  for label in labels {
   let q=app.images.matching(NSPredicate(format:"label == %@",label));snapshot(app,"picker-before-asset-readiness");XCTAssertTrue(q.firstMatch.waitForExistence(timeout:15),"Photo chrome can precede asynchronously loaded assets.");XCTAssertEqual(q.count,1)
   XCTAssertTrue(app.frame.contains(q.firstMatch.frame) && q.firstMatch.isHittable)
   let image=q.firstMatch;let bounds=image.frame
   var left=bounds.minX+8;var right=bounds.maxX-8
   for title in ["Cancel","Done","Search","Sort and Filter"] {
    for control in app.buttons.matching(NSPredicate(format:"label == %@",title)).allElementsBoundByIndex where control.isHittable && control.frame.intersects(bounds) {
     if control.frame.midX>bounds.midX {right=min(right,control.frame.minX-12)}
     else {left=max(left,control.frame.maxX+12)}
    }
   }
   XCTAssertGreaterThan(right-left,20)
   let point=CGPoint(x:(left+right)/2,y:bounds.midY)
   XCTAssertTrue(bounds.contains(point) && app.frame.contains(point))
   print("MM_PICKER_SAFE_POINT label=\(label) image=\(bounds) point=\(point)")
   XCTAssertFalse(image.isSelected,"Each input must start unselected; do not silently toggle an existing selection.")
   image.coordinate(withNormalizedOffset:.zero).withOffset(CGVector(dx:point.x-bounds.minX,dy:point.y-bounds.minY)).tap()
   if multiple {
    let selected=XCTNSPredicateExpectation(predicate:NSPredicate(format:"selected == true"),object:image)
    XCTAssertEqual(XCTWaiter.wait(for:[selected],timeout:5),.completed)
    snapshot(app,"picker-confirmed-selection-"+String(labels.firstIndex(of:label)!+1))
   }
  }
  if multiple { let done=app.buttons.matching(NSPredicate(format:"label == %@","Done"));XCTAssertEqual(done.count,1);XCTAssertTrue(done.firstMatch.isEnabled && done.firstMatch.isHittable);done.firstMatch.tap() }
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
