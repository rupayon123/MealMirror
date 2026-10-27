import AppKit
import ImageIO
import UniformTypeIdentifiers
let path=CommandLine.arguments[1]
let image=NSImage(size:NSSize(width:300,height:900))
image.lockFocus()
NSColor.white.setFill();NSRect(x:0,y:0,width:300,height:900).fill()
let rows=[("QA TALL LABEL",820.0),("NUTRITION FACTS",710.0),("Total Carbohydrate",580.0),("19 g per serving",470.0),("Layout fixture only",320.0),("NOT A FOOD CLAIM",180.0),("BOTTOM MARKER",55.0)]
for (text,y) in rows { (text as NSString).draw(in:NSRect(x:15,y:y,width:270,height:70),withAttributes:[.font:NSFont.systemFont(ofSize:21,weight:.semibold),.foregroundColor:NSColor.black]) }
image.unlockFocus()
var rect=NSRect(x:0,y:0,width:300,height:900)
guard let cg=image.cgImage(forProposedRect:&rect,context:nil,hints:nil),let dest=CGImageDestinationCreateWithURL(URL(fileURLWithPath:path) as CFURL,UTType.png.identifier as CFString,1,nil) else {fatalError("image destination")}
CGImageDestinationAddImage(dest,cg,[kCGImagePropertyExifDictionary:[kCGImagePropertyExifDateTimeOriginal:"2026:10:26 11:29:00"],kCGImagePropertyTIFFDictionary:[kCGImagePropertyTIFFDateTime:"2026:10:26 11:29:00"]] as CFDictionary)
precondition(CGImageDestinationFinalize(dest));print("Wrote original procedural300x900 test label")
