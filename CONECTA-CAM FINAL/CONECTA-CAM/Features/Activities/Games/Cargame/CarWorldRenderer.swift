//
//  CarWorldRenderer.swift
//  Conecta CAM
//
//  Dibuja el mundo de la carrera en un Canvas (rápido, aunque el nivel sea largo):
//  cielo, montañas y árboles con efecto de profundidad, suelo, obstáculos,
//  estrellas, puntos de control, meta y el carro.
//
//  Todo está hecho con formas, sin imágenes, salvo el dibujo del carro ("car").
//

import SwiftUI

enum CarWorldRenderer {

    private static let outline = Color(hex: 0x1F2937).opacity(0.75)

    static func draw(
        _ ctx: inout GraphicsContext,
        size: CGSize,
        engine: CarGameEngine,
        time: TimeInterval,
        reduceMotion: Bool
    ) {
        let level = engine.level
        let groundY = size.height * 0.74
        let camera = engine.cameraX(forWidth: size.width)
        let palette = level.palette(at: camera + size.width * 0.35)

        drawSky(&ctx, size: size, groundY: groundY, palette: palette)
        drawClouds(&ctx, size: size, camera: camera, palette: palette)
        drawMountains(&ctx, size: size, groundY: groundY, camera: camera, palette: palette)
        drawHills(&ctx, size: size, groundY: groundY, camera: camera, palette: palette)
        drawScenery(&ctx, size: size, groundY: groundY, camera: camera, level: level, palette: palette)
        drawGround(&ctx, size: size, groundY: groundY, camera: camera, palette: palette)
        drawPits(&ctx, size: size, groundY: groundY, camera: camera, level: level, palette: palette)
        drawMud(&ctx, size: size, groundY: groundY, camera: camera, level: level)
        drawCheckpoints(&ctx, size: size, groundY: groundY, camera: camera, level: level, carX: engine.carX)
        drawFinish(&ctx, size: size, groundY: groundY, camera: camera, level: level)
        drawHazards(&ctx, size: size, groundY: groundY, camera: camera, level: level)
        drawStars(&ctx, size: size, groundY: groundY, camera: camera, engine: engine, time: time, reduceMotion: reduceMotion)
        drawCar(&ctx, size: size, groundY: groundY, camera: camera, engine: engine, palette: palette, time: time, reduceMotion: reduceMotion)
        drawSnow(&ctx, size: size, camera: camera, level: level, time: time, reduceMotion: reduceMotion)
    }

    // MARK: - Utilidades

    /// Un número "al azar" entre 0 y 1 que siempre es el mismo para el mismo `i`.
    private static func noise(_ i: Int) -> CGFloat {
        let v = sin(Double(i) * 12.9898 + 4.1414) * 43758.5453
        return CGFloat(v - floor(v))
    }

    private static func wrap(_ value: CGFloat, _ modulus: CGFloat) -> CGFloat {
        let r = value.truncatingRemainder(dividingBy: modulus)
        return r < 0 ? r + modulus : r
    }

    /// Rango de índices visibles de una capa con `spacing` entre elementos y velocidad `factor`.
    private static func visibleRange(camera: CGFloat, width: CGFloat, spacing: CGFloat, factor: CGFloat) -> ClosedRange<Int> {
        let first = Int(floor(camera * factor / spacing)) - 1
        let last = Int(ceil((camera * factor + width) / spacing)) + 1
        return first...last
    }

    // MARK: - Fondo

    private static func drawSky(_ ctx: inout GraphicsContext, size: CGSize, groundY: CGFloat, palette: CarPalette) {
        let gradient = Gradient(colors: [palette.skyTop.color, palette.skyBottom.color])
        ctx.fill(
            Path(CGRect(origin: .zero, size: size)),
            with: .linearGradient(gradient, startPoint: .zero, endPoint: CGPoint(x: 0, y: groundY))
        )
    }

    private static func cloudPath(_ r: CGRect) -> Path {
        var p = Path()
        let h = r.height
        p.addRoundedRect(
            in: CGRect(x: r.minX, y: r.minY + h * 0.45, width: r.width, height: h * 0.55),
            cornerSize: CGSize(width: h * 0.275, height: h * 0.275)
        )
        p.addEllipse(in: CGRect(x: r.minX + r.width * 0.12, y: r.minY + h * 0.18, width: r.width * 0.34, height: h * 0.62))
        p.addEllipse(in: CGRect(x: r.minX + r.width * 0.36, y: r.minY, width: r.width * 0.38, height: h * 0.80))
        p.addEllipse(in: CGRect(x: r.minX + r.width * 0.62, y: r.minY + h * 0.25, width: r.width * 0.28, height: h * 0.55))
        return p
    }

    private static func drawClouds(_ ctx: inout GraphicsContext, size: CGSize, camera: CGFloat, palette: CarPalette) {
        let spacing: CGFloat = 520
        let factor: CGFloat = 0.12
        for i in visibleRange(camera: camera, width: size.width, spacing: spacing, factor: factor) {
            let width = 150 + 100 * noise(i)
            let x = CGFloat(i) * spacing + 120 * noise(i + 11) - camera * factor
            let y = 40 + 110 * noise(i + 23)
            let rect = CGRect(x: x, y: y, width: width, height: width * 0.5)
            ctx.fill(cloudPath(rect), with: .color(palette.cloud.color.opacity(0.9)))
        }
    }

    private static func drawMountains(_ ctx: inout GraphicsContext, size: CGSize, groundY: CGFloat, camera: CGFloat, palette: CarPalette) {
        let spacing: CGFloat = 460
        let factor: CGFloat = 0.2
        let color = palette.farMountains.color
        for i in visibleRange(camera: camera, width: size.width, spacing: spacing, factor: factor) {
            let centerX = CGFloat(i) * spacing + 80 * noise(i + 3) - camera * factor
            let height = 150 + 130 * noise(i)
            let half = 210 + 70 * noise(i + 5)
            var p = Path()
            p.move(to: CGPoint(x: centerX - half, y: groundY))
            p.addLine(to: CGPoint(x: centerX, y: groundY - height))
            p.addLine(to: CGPoint(x: centerX + half, y: groundY))
            p.closeSubpath()
            ctx.fill(p, with: .color(color))
            ctx.stroke(p, with: .color(color), style: StrokeStyle(lineWidth: 18, lineJoin: .round))
        }
    }

    private static func drawHills(_ ctx: inout GraphicsContext, size: CGSize, groundY: CGFloat, camera: CGFloat, palette: CarPalette) {
        let factor: CGFloat = 0.4
        var p = Path()
        p.move(to: CGPoint(x: -20, y: groundY))
        var x: CGFloat = -20
        while x <= size.width + 20 {
            let worldX = Double(x + camera * factor)
            let wave1 = 30 * CGFloat(sin(worldX * 0.006))
            let wave2 = 16 * CGFloat(sin(worldX * 0.0141 + 1))
            p.addLine(to: CGPoint(x: x, y: groundY - 46 - wave1 - wave2))
            x += 20
        }
        p.addLine(to: CGPoint(x: size.width + 20, y: groundY))
        p.closeSubpath()
        ctx.fill(p, with: .color(palette.hills.color))
    }

    // MARK: - Árboles, cactus y pinos de fondo

    private static func drawScenery(_ ctx: inout GraphicsContext, size: CGSize, groundY: CGFloat, camera: CGFloat, level: CarLevel, palette: CarPalette) {
        let spacing: CGFloat = 230
        let factor: CGFloat = 0.65
        for i in visibleRange(camera: camera, width: size.width, spacing: spacing, factor: factor) {
            let layerX = CGFloat(i) * spacing + 70 * noise(i + 7)
            let x = layerX - camera * factor
            let style = level.zones[level.zoneIndex(at: layerX / factor)].style
            let scale = 0.8 + 0.6 * noise(i + 13)
            drawSceneryItem(&ctx, style: style, x: x, baseY: groundY + 2, scale: scale, variant: noise(i), color: palette.trees)
        }
    }

    private static func drawSceneryItem(_ ctx: inout GraphicsContext, style: CarZoneStyle, x: CGFloat, baseY: CGFloat, scale s: CGFloat, variant: CGFloat, color: CarRGB) {
        switch style {
        case .meadow where variant < 0.55:
            // Árbol redondo
            let trunk = CGRect(x: x - 7 * s, y: baseY - 46 * s, width: 14 * s, height: 46 * s)
            ctx.fill(Path(trunk), with: .color(Color(hex: 0x8B5A2B)))
            let crown = CGRect(x: x - 36 * s, y: baseY - 104 * s, width: 72 * s, height: 66 * s)
            ctx.fill(Path(ellipseIn: crown), with: .color(color.color))
            let shine = CGRect(x: x - 24 * s, y: baseY - 94 * s, width: 24 * s, height: 16 * s)
            ctx.fill(Path(ellipseIn: shine), with: .color(color.lighter(0.25).color.opacity(0.7)))
        case .meadow, .forest:
            ctx.fill(pinePath(x: x, baseY: baseY, scale: s), with: .color(color.color))
        case .desert:
            let rect = CGRect(x: x - 23 * s, y: baseY - 96 * s, width: 46 * s, height: 96 * s)
            ctx.fill(cactusPath(in: rect), with: .color(color.color))
        case .snow:
            ctx.fill(pinePath(x: x, baseY: baseY, scale: s), with: .color(color.color))
            ctx.fill(pineSnowPath(x: x, baseY: baseY, scale: s), with: .color(.white))
        }
    }

    private static let pineTiers: [(top: CGFloat, bottom: CGFloat, half: CGFloat)] = [
        (0.00, 0.42, 0.28), (0.22, 0.68, 0.38), (0.45, 0.88, 0.50)
    ]

    private static func pinePath(x: CGFloat, baseY: CGFloat, scale s: CGFloat) -> Path {
        var p = Path()
        let w = 74 * s
        let h = 120 * s
        let top = baseY - h
        for tier in pineTiers {
            p.move(to: CGPoint(x: x, y: top + h * tier.top))
            p.addLine(to: CGPoint(x: x + w * tier.half, y: top + h * tier.bottom))
            p.addLine(to: CGPoint(x: x - w * tier.half, y: top + h * tier.bottom))
            p.closeSubpath()
        }
        p.addRect(CGRect(x: x - 6 * s, y: baseY - h * 0.14, width: 12 * s, height: h * 0.14))
        return p
    }

    /// Nieve sobre la parte de arriba de cada nivel del pino.
    private static func pineSnowPath(x: CGFloat, baseY: CGFloat, scale s: CGFloat) -> Path {
        var p = Path()
        let w = 74 * s
        let h = 120 * s
        let top = baseY - h
        for tier in pineTiers {
            let capBottom = tier.top + (tier.bottom - tier.top) * 0.42
            let capHalf = tier.half * 0.42
            p.move(to: CGPoint(x: x, y: top + h * tier.top))
            p.addLine(to: CGPoint(x: x + w * capHalf, y: top + h * capBottom))
            p.addLine(to: CGPoint(x: x - w * capHalf, y: top + h * capBottom))
            p.closeSubpath()
        }
        return p
    }

    private static func cactusPath(in r: CGRect) -> Path {
        var p = Path()
        let bodyWidth = r.width * 0.52
        let armWidth = r.width * 0.28
        let bodyCorner = CGSize(width: bodyWidth / 2, height: bodyWidth / 2)
        let armCorner = CGSize(width: armWidth / 2, height: armWidth / 2)
        // cuerpo
        p.addRoundedRect(in: CGRect(x: r.midX - bodyWidth / 2, y: r.minY, width: bodyWidth, height: r.height), cornerSize: bodyCorner)
        // brazo izquierdo
        p.addRoundedRect(in: CGRect(x: r.minX, y: r.minY + r.height * 0.40, width: r.width * 0.42, height: armWidth), cornerSize: armCorner)
        p.addRoundedRect(in: CGRect(x: r.minX, y: r.minY + r.height * 0.20, width: armWidth, height: r.height * 0.40), cornerSize: armCorner)
        // brazo derecho
        p.addRoundedRect(in: CGRect(x: r.midX, y: r.minY + r.height * 0.55, width: r.width * 0.50, height: armWidth), cornerSize: armCorner)
        p.addRoundedRect(in: CGRect(x: r.maxX - armWidth, y: r.minY + r.height * 0.32, width: armWidth, height: r.height * 0.40), cornerSize: armCorner)
        return p
    }

    // MARK: - Suelo, agujeros y charcos

    private static func drawGround(_ ctx: inout GraphicsContext, size: CGSize, groundY: CGFloat, camera: CGFloat, palette: CarPalette) {
        let below = size.height - groundY
        ctx.fill(Path(CGRect(x: 0, y: groundY, width: size.width, height: below)), with: .color(palette.ground.color))
        ctx.fill(Path(CGRect(x: 0, y: groundY, width: size.width, height: 22)), with: .color(palette.groundTop.color))
        ctx.fill(Path(CGRect(x: 0, y: groundY + 22, width: size.width, height: 4)), with: .color(palette.ground.darker(0.18).color))

        // Rayitas que pasan rápido: dan la sensación de velocidad.
        let spacing: CGFloat = 130
        let marks = palette.ground.darker(0.15).color
        for i in visibleRange(camera: camera, width: size.width, spacing: spacing, factor: 1) {
            let x = CGFloat(i) * spacing + 40 * noise(i + 31) - camera
            let y = groundY + 46 + 50 * noise(i + 37)
            let width = 30 + 30 * noise(i + 41)
            ctx.fill(Path(roundedRect: CGRect(x: x, y: y, width: width, height: 8), cornerRadius: 4), with: .color(marks))
        }

        // Línea oscura arriba: separa bien el suelo del cielo (sobre todo en la nieve).
        var line = Path()
        line.move(to: CGPoint(x: 0, y: groundY))
        line.addLine(to: CGPoint(x: size.width, y: groundY))
        ctx.stroke(line, with: .color(palette.ground.darker(0.4).color), lineWidth: 3)
    }

    private static func drawPits(_ ctx: inout GraphicsContext, size: CGSize, groundY: CGFloat, camera: CGFloat, level: CarLevel, palette: CarPalette) {
        let gradient = Gradient(colors: [Color(hex: 0x2B2F4A), Color(hex: 0x0B0D1A)])
        let height = size.height - groundY
        for hazard in level.hazards where hazard.kind == .pit {
            let x = hazard.x - camera
            if x + hazard.width < -10 || x > size.width + 10 { continue }
            let rect = CGRect(x: x, y: groundY, width: hazard.width, height: height)
            ctx.fill(
                Path(rect),
                with: .linearGradient(gradient, startPoint: CGPoint(x: 0, y: groundY), endPoint: CGPoint(x: 0, y: size.height))
            )
            let wall = palette.ground.darker(0.35).color
            ctx.fill(Path(CGRect(x: x - 3, y: groundY, width: 6, height: height)), with: .color(wall))
            ctx.fill(Path(CGRect(x: x + hazard.width - 3, y: groundY, width: 6, height: height)), with: .color(wall))
        }
    }

    private static func mudColors(_ style: CarZoneStyle) -> (fill: CarRGB, dark: CarRGB) {
        switch style {
        case .meadow: return (CarRGB(0x8B5E34), CarRGB(0x5A3A1E))
        case .desert: return (CarRGB(0xB98544), CarRGB(0x7C5420))
        case .forest: return (CarRGB(0x6B4A2B), CarRGB(0x3F2A16))
        case .snow:   return (CarRGB(0xE6F4FF), CarRGB(0x7FB4D8))
        }
    }

    private static func drawMud(_ ctx: inout GraphicsContext, size: CGSize, groundY: CGFloat, camera: CGFloat, level: CarLevel) {
        for hazard in level.hazards where hazard.kind == .slow {
            let x = hazard.x - camera
            if x + hazard.width < -10 || x > size.width + 10 { continue }
            let colors = mudColors(level.zones[level.zoneIndex(at: hazard.midX)].style)
            let rect = CGRect(x: x, y: groundY - 6, width: hazard.width, height: 28)
            ctx.fill(Path(ellipseIn: rect), with: .color(colors.fill.color))
            ctx.stroke(Path(ellipseIn: rect), with: .color(colors.dark.color), lineWidth: 3)
            for k in 0..<3 {
                let blotX = x + hazard.width * (0.2 + 0.3 * CGFloat(k))
                let blot = CGRect(x: blotX - 18, y: groundY + 2, width: 36, height: 10)
                ctx.fill(Path(ellipseIn: blot), with: .color(colors.dark.color.opacity(0.6)))
            }
        }
    }

    // MARK: - Puntos de control y meta

    private static func drawCheckpoints(_ ctx: inout GraphicsContext, size: CGSize, groundY: CGFloat, camera: CGFloat, level: CarLevel, carX: CGFloat) {
        for checkpointX in level.checkpoints {
            let x = checkpointX - camera
            if x < -90 || x > size.width + 90 { continue }
            let reached = carX >= checkpointX
            let pole = CGRect(x: x - 3, y: groundY - 140, width: 6, height: 140)
            ctx.fill(Path(pole), with: .color(.white))
            ctx.stroke(Path(pole), with: .color(outline), lineWidth: 2)

            var flag = Path()
            flag.move(to: CGPoint(x: x + 3, y: groundY - 140))
            flag.addLine(to: CGPoint(x: x + 70, y: groundY - 116))
            flag.addLine(to: CGPoint(x: x + 3, y: groundY - 92))
            flag.closeSubpath()
            ctx.fill(flag, with: .color(reached ? Color(hex: 0x43C463) : CarStyle.starYellow))
            ctx.stroke(flag, with: .color(outline), style: StrokeStyle(lineWidth: 3, lineJoin: .round))
        }
    }

    private static func drawFinish(_ ctx: inout GraphicsContext, size: CGSize, groundY: CGFloat, camera: CGFloat, level: CarLevel) {
        let x = level.length - camera
        if x < -140 || x > size.width + 140 { return }

        for poleX in [x - 94, x + 86] {
            let pole = CGRect(x: poleX, y: groundY - 200, width: 8, height: 200)
            ctx.fill(Path(pole), with: .color(.white))
            ctx.stroke(Path(pole), with: .color(outline), lineWidth: 2)
        }

        // Cartel de cuadros
        let square: CGFloat = 20
        let left = x - 90
        let top = groundY - 200
        for row in 0..<3 {
            for column in 0..<9 {
                let isDark = (row + column).isMultiple(of: 2)
                let rect = CGRect(x: left + CGFloat(column) * square, y: top + CGFloat(row) * square, width: square, height: square)
                ctx.fill(Path(rect), with: .color(isDark ? Color(hex: 0x1F2937) : .white))
            }
        }
        ctx.stroke(Path(CGRect(x: left, y: top, width: square * 9, height: square * 3)), with: .color(outline), lineWidth: 3)
    }

    // MARK: - Obstáculos

    private static func drawHazards(_ ctx: inout GraphicsContext, size: CGSize, groundY: CGFloat, camera: CGFloat, level: CarLevel) {
        for hazard in level.hazards where hazard.isSolid {
            let x = hazard.x - camera
            if x + hazard.width < -10 || x > size.width + 10 { continue }
            let rect = CGRect(x: x, y: groundY - hazard.height, width: hazard.width, height: hazard.height)
            switch hazard.kind {
            case .spikes: drawSpikes(&ctx, rect)
            case .rock:   drawRock(&ctx, rect)
            case .log:    drawLog(&ctx, rect)
            case .cactus: drawCactus(&ctx, rect)
            case .ice:    drawIce(&ctx, rect)
            case .pit, .slow: break
            }
        }
    }

    private static func drawSpikes(_ ctx: inout GraphicsContext, _ r: CGRect) {
        let count = 3
        let toothWidth = r.width / CGFloat(count)
        for k in 0..<count {
            let left = r.minX + toothWidth * CGFloat(k)
            let tip = CGPoint(x: left + toothWidth / 2, y: r.minY)
            var tooth = Path()
            tooth.move(to: CGPoint(x: left, y: r.maxY))
            tooth.addLine(to: tip)
            tooth.addLine(to: CGPoint(x: left + toothWidth, y: r.maxY))
            tooth.closeSubpath()
            ctx.fill(tooth, with: .color(Color(hex: 0xE53935)))

            var shine = Path()
            shine.move(to: tip)
            shine.addLine(to: CGPoint(x: left, y: r.maxY))
            shine.addLine(to: CGPoint(x: left + toothWidth / 2, y: r.maxY))
            shine.closeSubpath()
            ctx.fill(shine, with: .color(Color(hex: 0xFF8A80)))
            ctx.stroke(tooth, with: .color(outline), style: StrokeStyle(lineWidth: 3, lineJoin: .round))
        }
        ctx.fill(Path(CGRect(x: r.minX, y: r.maxY - 5, width: r.width, height: 5)), with: .color(Color(hex: 0x4B5066)))
    }

    private static func drawRock(_ ctx: inout GraphicsContext, _ r: CGRect) {
        var dome = Path()
        dome.move(to: CGPoint(x: r.minX, y: r.maxY))
        dome.addQuadCurve(to: CGPoint(x: r.midX, y: r.minY), control: CGPoint(x: r.minX - 2, y: r.minY + r.height * 0.1))
        dome.addQuadCurve(to: CGPoint(x: r.maxX, y: r.maxY), control: CGPoint(x: r.maxX + 2, y: r.minY + r.height * 0.1))
        dome.closeSubpath()
        ctx.fill(dome, with: .color(Color(hex: 0x8D93A8)))
        ctx.stroke(dome, with: .color(outline), style: StrokeStyle(lineWidth: 3, lineJoin: .round))

        let shine = CGRect(x: r.minX + r.width * 0.22, y: r.minY + r.height * 0.2, width: r.width * 0.26, height: r.height * 0.16)
        ctx.fill(Path(ellipseIn: shine), with: .color(.white.opacity(0.4)))

        var crack = Path()
        crack.move(to: CGPoint(x: r.minX + r.width * 0.62, y: r.minY + r.height * 0.18))
        crack.addLine(to: CGPoint(x: r.minX + r.width * 0.56, y: r.minY + r.height * 0.5))
        crack.addLine(to: CGPoint(x: r.minX + r.width * 0.66, y: r.minY + r.height * 0.78))
        ctx.stroke(crack, with: .color(outline.opacity(0.6)), style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
    }

    private static func drawLog(_ ctx: inout GraphicsContext, _ r: CGRect) {
        let body = Path(roundedRect: r, cornerRadius: 16)
        ctx.fill(body, with: .color(Color(hex: 0x9C6B3A)))
        ctx.stroke(body, with: .color(outline), lineWidth: 3)

        for fraction in [0.35, 0.65] {
            var grain = Path()
            let y = r.minY + r.height * CGFloat(fraction)
            grain.move(to: CGPoint(x: r.minX + r.width * 0.28, y: y))
            grain.addLine(to: CGPoint(x: r.minX + r.width * 0.9, y: y))
            ctx.stroke(grain, with: .color(Color(hex: 0x7A5128)), style: StrokeStyle(lineWidth: 2.5, lineCap: .round))
        }

        // Extremo cortado a la izquierda
        let cap = CGRect(x: r.minX - 2, y: r.minY, width: r.height * 0.7, height: r.height)
        ctx.fill(Path(ellipseIn: cap), with: .color(Color(hex: 0xC48A4F)))
        ctx.stroke(Path(ellipseIn: cap), with: .color(outline), lineWidth: 3)
        ctx.stroke(Path(ellipseIn: cap.insetBy(dx: cap.width * 0.22, dy: cap.height * 0.22)), with: .color(Color(hex: 0x9C6B3A)), lineWidth: 2)
    }

    private static func drawCactus(_ ctx: inout GraphicsContext, _ r: CGRect) {
        let shape = cactusPath(in: r)
        ctx.fill(shape, with: .color(Color(hex: 0x3FA34D)))
        ctx.stroke(shape, with: .color(Color(hex: 0x1F6B2E)), style: StrokeStyle(lineWidth: 3, lineJoin: .round))
        // Espinitas
        for k in 0..<4 {
            let dot = CGRect(x: r.midX - 2, y: r.minY + r.height * (0.12 + 0.2 * CGFloat(k)), width: 4, height: 4)
            ctx.fill(Path(ellipseIn: dot), with: .color(.white.opacity(0.85)))
        }
    }

    private static func drawIce(_ ctx: inout GraphicsContext, _ r: CGRect) {
        let points: [(CGFloat, CGFloat)] = [(0, 1), (0.12, 0.38), (0.38, 0), (0.62, 0.22), (0.78, 0.05), (1, 1)]
        var crystal = Path()
        for (index, point) in points.enumerated() {
            let p = CGPoint(x: r.minX + r.width * point.0, y: r.minY + r.height * point.1)
            if index == 0 { crystal.move(to: p) } else { crystal.addLine(to: p) }
        }
        crystal.closeSubpath()
        ctx.fill(crystal, with: .color(Color(hex: 0xA5E3FF)))

        var facet = Path()
        facet.move(to: CGPoint(x: r.minX + r.width * 0.38, y: r.minY))
        facet.addLine(to: CGPoint(x: r.minX + r.width * 0.2, y: r.minY + r.height * 0.62))
        facet.addLine(to: CGPoint(x: r.minX + r.width * 0.46, y: r.minY + r.height * 0.62))
        facet.closeSubpath()
        ctx.fill(facet, with: .color(.white.opacity(0.55)))
        ctx.stroke(crystal, with: .color(Color(hex: 0x3F8FC4)), style: StrokeStyle(lineWidth: 3, lineJoin: .round))
    }

    // MARK: - Estrellas

    private static func starPath(center c: CGPoint, outer: CGFloat, inner: CGFloat) -> Path {
        var p = Path()
        for k in 0..<10 {
            let radius = k.isMultiple(of: 2) ? outer : inner
            let angle = Double(k) * Double.pi / 5 - Double.pi / 2
            let point = CGPoint(x: c.x + radius * CGFloat(cos(angle)), y: c.y + radius * CGFloat(sin(angle)))
            if k == 0 { p.move(to: point) } else { p.addLine(to: point) }
        }
        p.closeSubpath()
        return p
    }

    private static func drawStars(_ ctx: inout GraphicsContext, size: CGSize, groundY: CGFloat, camera: CGFloat, engine: CarGameEngine, time: TimeInterval, reduceMotion: Bool) {
        for star in engine.level.stars {
            let x = star.x - camera
            if x < -30 || x > size.width + 30 { continue }
            if engine.collectedStars.contains(star.id) { continue }
            let bob: CGFloat = reduceMotion ? 0 : CGFloat(sin(time * 3 + Double(star.id))) * 3
            let shape = starPath(center: CGPoint(x: x, y: groundY - star.y + bob), outer: 19, inner: 8.5)
            ctx.fill(shape, with: .color(CarStyle.starYellow))
            ctx.stroke(shape, with: .color(Color(hex: 0xE59800)), style: StrokeStyle(lineWidth: 2.5, lineJoin: .round))
        }
    }

    // MARK: - Carro

    private static func drawCar(_ ctx: inout GraphicsContext, size: CGSize, groundY: CGFloat, camera: CGFloat, engine: CarGameEngine, palette: CarPalette, time: TimeInterval, reduceMotion: Bool) {
        let screenX = engine.carX - camera
        let carY = engine.carY
        let bottomY = groundY + 8 - carY

        // Polvo
        let dustColor = palette.groundTop.lighter(0.4).color
        for puff in engine.dust {
            let t = CGFloat(puff.age / puff.life)
            let radius = puff.size * (1 + t * 1.5)
            let rect = CGRect(x: puff.x - camera - radius, y: groundY + 4 - puff.y - radius, width: radius * 2, height: radius * 2)
            ctx.fill(Path(ellipseIn: rect), with: .color(dustColor.opacity(0.7 * Double(1 - t))))
        }

        // Sombra: se achica cuando el carro sube (ayuda a ver dónde va a caer)
        if carY >= 0 {
            let lift = min(carY / 260, 1)
            let width = 120 * (1 - 0.4 * lift)
            let shadow = CGRect(x: screenX - width / 2, y: groundY + 2, width: width, height: 16)
            ctx.fill(Path(ellipseIn: shadow), with: .color(.black.opacity(0.22 * Double(1 - 0.5 * lift))))
        }

        // Transparencia: se desvanece al caer; parpadea despacio después de un golpe.
        var alpha: Double = 1
        if carY < 0 {
            alpha = max(0, 1 + Double(carY) / 120)
        } else if engine.invulnerable > 0 {
            alpha = reduceMotion ? 0.6 : (Int(time * 5) % 2 == 0 ? 0.45 : 1)
        }

        // El carro se inclina un poco al subir y al bajar.
        let tilt = max(-12, min(12, -engine.verticalSpeed / 50))

        var carContext = ctx
        carContext.opacity = alpha
        carContext.translateBy(x: screenX, y: bottomY - 49)
        carContext.rotate(by: .degrees(Double(tilt)))
        carContext.draw(Image("car"), in: CGRect(x: -74, y: -49, width: 148, height: 98))
    }

    // MARK: - Nieve que cae (solo en la zona de nieve)

    private static func drawSnow(_ ctx: inout GraphicsContext, size: CGSize, camera: CGFloat, level: CarLevel, time: TimeInterval, reduceMotion: Bool) {
        guard !reduceMotion,
              let snowIndex = level.zones.firstIndex(where: { $0.style == .snow }) else { return }
        let start = CGFloat(snowIndex) * CarLevel.zoneLength
        let amount = min(max((camera + size.width * 0.5 - (start - 500)) / 500, 0), 1)
        guard amount > 0 else { return }

        let seconds = CGFloat(time)
        for k in 0..<45 {
            let n = noise(k)
            let drift = CGFloat(sin(Double(seconds) * 0.7 + Double(k))) * 18
            let baseX = noise(k + 50) * size.width - camera * 0.4
            let x = wrap(baseX + drift, size.width)
            let fall = seconds * (40 + 40 * n)
            let y = wrap(fall + noise(k + 90) * size.height, size.height)
            let radius = 2 + 2.5 * n
            let flake = CGRect(x: x - radius, y: y - radius, width: radius * 2, height: radius * 2)
            ctx.fill(Path(ellipseIn: flake), with: .color(.white.opacity(0.85 * Double(amount))))
        }
    }
}
