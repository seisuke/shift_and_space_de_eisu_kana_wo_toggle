#!/usr/bin/env swift
import AppKit

let arguments = CommandLine.arguments
guard arguments.count == 2 else {
    fputs("usage: generate_icon.swift OUTPUT.png\n", stderr)
    exit(2)
}

let size = NSSize(width: 1024, height: 1024)
let image = NSImage(size: size)
image.lockFocus()

let background = NSBezierPath(
    roundedRect: NSRect(x: 64, y: 64, width: 896, height: 896),
    xRadius: 210,
    yRadius: 210
)
NSColor(calibratedRed: 0.12, green: 0.15, blue: 0.20, alpha: 1).setFill()
background.fill()

let paragraph = NSMutableParagraphStyle()
paragraph.alignment = .center

let font = NSFont(name: "HiraginoSans-W6", size: 610)
    ?? NSFont.systemFont(ofSize: 610, weight: .bold)
let attributes: [NSAttributedString.Key: Any] = [
    .font: font,
    .foregroundColor: NSColor.white,
    .paragraphStyle: paragraph
]

let glyph = NSAttributedString(string: "砥", attributes: attributes)
glyph.draw(in: NSRect(x: 100, y: 172, width: 824, height: 690))
image.unlockFocus()

guard let tiff = image.tiffRepresentation,
      let bitmap = NSBitmapImageRep(data: tiff),
      let png = bitmap.representation(using: .png, properties: [:]) else {
    fputs("failed to render icon\n", stderr)
    exit(1)
}

try png.write(to: URL(fileURLWithPath: arguments[1]))
