import Foundation
import XCTest
final class MealMirrorUITests:XCTestCase {
 @MainActor func testExact28TallLabelInspection() throws {
  continueAfterFailure=false
  let app=XCUIApplication(bundleIdentifier:"com.mealmirror.swiftchallenge")
  app.launchArguments=["-carbin.onboarding.completed","YES"];app.launch()
  defer { snapshot(app,"99-final");app.terminate() }
  tap(app.buttons["carbin.home.library"],in:app)
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
  let originals:Set<String>=["Photo, October 27, 6:15 AM","Photo, October 01, 4:51 AM","Photo, March 30, 2018, 3:14 PM","Photo, August 08, 2012, 5:55 PM","Photo, August 08, 2012, 5:29 PM","Photo, August 08, 2012, 2:52 PM","Photo, March 12, 2011, 7:17 PM","Photo, October 09, 2009, 5:09 PM"]
  let images=app.images.matching(NSPredicate(format:"label BEGINSWITH %@","Photo,"))
  let added=Set(images.allElementsBoundByIndex.map(\.label)).subtracting(originals)
  XCTAssertEqual(added.count,1,"Exactly one newly seeded procedural label must be identifiable by observed picker label.")
  guard let tall=added.first else {XCTFail("No observed added fixture");return}
  print("MM_TALL_FIXTURE_OBSERVED_LABEL \(tall)")
  snapshot(app,"01-observed-single-added-tall-fixture")
  let cancel=app.buttons.matching(NSPredicate(format:"label == %@","Cancel"));XCTAssertEqual(cancel.count,1);cancel.firstMatch.tap()
  XCTAssertTrue(app.staticTexts["No photo selected"].waitForExistence(timeout:10))
  tap(app.buttons["carbin.meal.labelLibrary"],in:app)
  choose([tall],in:app,multiple:false)
  let label=role("Selected nutrition label photo",in:app)
  XCTAssertTrue(label.waitForExistence(timeout:20));reveal(label,in:app)
  XCTAssertTrue(app.frame.contains(label.frame))
  XCTAssertFalse(app.buttons["carbin.meal.analyze"].isEnabled)
  XCTAssertFalse(role("Selected meal photo 1",in:app).exists)
  snapshot(app,"02-whole-tall-label-no-food-no-analysis")
  tap(app.buttons["carbin.meal.viewLabel"],in:app)
  inspectLabel(app,wide:false,prefix:"tall-viewer")
  XCTAssertTrue(label.exists && !app.buttons["carbin.meal.analyze"].isEnabled)
  snapshot(app,"tall-after-close-unchanged-role")
  let remove=label.buttons.matching(NSPredicate(format:"identifier BEGINSWITH %@","carbin.meal.removePhoto."));XCTAssertEqual(remove.count,1)
  tap(remove.firstMatch,in:app);XCTAssertFalse(label.exists)
  XCTAssertTrue(app.buttons["carbin.meal.labelLibrary"].exists)
  snapshot(app,"03-tall-label-removal-restores-picker")
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
