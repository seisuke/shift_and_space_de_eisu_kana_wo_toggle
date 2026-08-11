#!/usr/bin/env swift
import AppKit
import CoreText

guard CommandLine.arguments.count == 2 else {
    fputs("usage: generate_status_icons.swift OUTPUT_DIRECTORY\n", stderr)
    exit(2)
}

let outputDirectory = URL(fileURLWithPath: CommandLine.arguments[1], isDirectory: true)
try FileManager.default.createDirectory(at: outputDirectory, withIntermediateDirectories: true)

func render(_ text: String, to filename: String) throws {
    let canvasSize = NSSize(width: 44, height: 44)
    let image = NSImage(size: canvasSize, flipped: false) { rect in
        guard let scalar = text.utf16.first,
              let context = NSGraphicsContext.current?.cgContext else {
            return false
        }

        let baseFont = NSFont.systemFont(ofSize: 38, weight: .bold) as CTFont
        let font = CTFontCreateForString(
            baseFont,
            text as CFString,
            CFRange(location: 0, length: text.utf16.count)
        )
        var character = UniChar(scalar)
        var glyph = CGGlyph()
        guard CTFontGetGlyphsForCharacters(font, &character, &glyph, 1) else {
            return false
        }

        var glyphForBounds = glyph
        let bounds = CTFontGetBoundingRectsForGlyphs(
            font,
            .default,
            &glyphForBounds,
            nil,
            1
        )
        var position = CGPoint(
            x: rect.midX - bounds.midX,
            y: rect.midY - bounds.midY
        )

        context.setFillColor(NSColor.black.cgColor)
        CTFontDrawGlyphs(font, &glyph, &position, 1, context)
        return true
    }

    guard let tiff = image.tiffRepresentation,
          let bitmap = NSBitmapImageRep(data: tiff),
          let png = bitmap.representation(using: .png, properties: [:]) else {
        throw CocoaError(.fileWriteUnknown)
    }
    try png.write(to: outputDirectory.appendingPathComponent(filename))
}

try render("砥", to: "StatusKana.png")
try render("T", to: "StatusEisu.png")
