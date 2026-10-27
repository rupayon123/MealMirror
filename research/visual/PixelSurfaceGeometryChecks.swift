import Foundation
import SwiftUI
struct PixelRoundedRectangle: InsettableShape {
    var cornerRadius: CGFloat = 12
    private var insetAmount: CGFloat = 0

    init(cornerRadius: CGFloat = 12) { self.cornerRadius = cornerRadius }

    func inset(by amount: CGFloat) -> Self {
        var copy = self
        copy.insetAmount += amount
        return copy
    }

    func path(in rect: CGRect) -> Path {
        let box = rect.insetBy(dx: insetAmount, dy: insetAmount)
        guard box.width > 0, box.height > 0 else { return Path() }
        let u = min(max(0, floor((cornerRadius - insetAmount) / 3)), min(box.width, box.height) / 4)
        let x = box.minX, y = box.minY, right = box.maxX, bottom = box.maxY
        return Path { path in
            path.move(to: CGPoint(x: x + 2 * u, y: y))
            for point in [
                CGPoint(x: right - 2 * u, y: y),
                CGPoint(x: right - 2 * u, y: y + u),
                CGPoint(x: right - u, y: y + u),
                CGPoint(x: right - u, y: y + 2 * u),
                CGPoint(x: right, y: y + 2 * u),
                CGPoint(x: right, y: bottom - 2 * u),
                CGPoint(x: right - u, y: bottom - 2 * u),
                CGPoint(x: right - u, y: bottom - u),
                CGPoint(x: right - 2 * u, y: bottom - u),
                CGPoint(x: right - 2 * u, y: bottom),
                CGPoint(x: x + 2 * u, y: bottom),
                CGPoint(x: x + 2 * u, y: bottom - u),
                CGPoint(x: x + u, y: bottom - u),
                CGPoint(x: x + u, y: bottom - 2 * u),
                CGPoint(x: x, y: bottom - 2 * u),
                CGPoint(x: x, y: y + 2 * u),
                CGPoint(x: x + u, y: y + 2 * u),
                CGPoint(x: x + u, y: y + u),
                CGPoint(x: x + 2 * u, y: y + u)
            ] { path.addLine(to: point) }
            path.closeSubpath()
        }
    }
}

@main struct Checks {
 static func main() throws {
  var failures:[String]=[];var count=0
  func check(_ name:String,_ ok:Bool){count += 1;if !ok{failures.append(name)}}
  for size in [(44.0,44.0),(375.0,150.0),(768.0,80.0),(24.0,24.0),(3.0,3.0)] {
   for radius in [0.0,5.0,8.0,9.0,12.0,18.0] {
    let rect=CGRect(x:7,y:11,width:size.0,height:size.1)
    let path=PixelRoundedRectangle(cornerRadius:radius).path(in:rect).cgPath
    check("bounds",path.boundingBoxOfPath == rect)
    check("center",path.contains(CGPoint(x:rect.midX,y:rect.midY)))
    check("outside",!path.contains(CGPoint(x:rect.minX-1,y:rect.midY)))
    var closed=0;var curves=0
    path.applyWithBlock { element in
     if element.pointee.type == .closeSubpath {closed += 1}
     if element.pointee.type == .addCurveToPoint || element.pointee.type == .addQuadCurveToPoint {curves += 1}
    }
    check("oneclosedcontour",closed==1);check("steppednotcurved",curves==0)
    for frac in [0.2,0.5,0.8] {
     let a=CGPoint(x:rect.minX+rect.width*frac,y:rect.minY+0.5)
     let b=CGPoint(x:rect.maxX-rect.width*frac,y:a.y)
     check("symmetry",path.contains(a)==path.contains(b))
    }
   }
  }
  let rect=CGRect(x:0,y:0,width:100,height:50)
  check("inset",PixelRoundedRectangle(cornerRadius:12).inset(by:2).path(in:rect).cgPath.boundingBoxOfPath == rect.insetBy(dx:2,dy:2))
  check("empty",PixelRoundedRectangle().path(in:.zero).isEmpty)
  check("excessinset",PixelRoundedRectangle().inset(by:100).path(in:rect).isEmpty)
  let result:[String:Any] = ["checks":count,"failures":failures,"passed":failures.isEmpty,"scope":"Exact extracted SwiftUI shape geometry on macOS; no iOS visual, text/layout, accessibility or human comprehension acceptance."]
  print(String(decoding:try JSONSerialization.data(withJSONObject:result,options:[.prettyPrinted,.sortedKeys]),as:UTF8.self))
  if !failures.isEmpty {exit(1)}
 }
}
