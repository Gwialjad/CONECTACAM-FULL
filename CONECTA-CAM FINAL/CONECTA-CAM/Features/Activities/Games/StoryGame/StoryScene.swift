//
//  StoryScene.swift
//  Conecta CAM
//
//  Paleta y paisaje de "Historia en cadena".
//  Jugador 1 = azul, jugador 2 = rojo. Todo está dibujado con formas de SwiftUI,
//  así que no necesita imágenes nuevas en Assets.
//

import SwiftUI

// MARK: - Paleta por jugador

struct StoryTheme {
    /// Color fuerte: botones y rótulos con texto blanco (contraste ≥ 5.5:1).
    let accent: Color
    /// Color muy oscuro: texto sobre blanco o sobre `chip` (contraste ≥ 8:1).
    let deep: Color
    /// Bordes y fondos suaves.
    let pale: Color
    /// Relleno de las palabras del banco.
    let chip: Color

    // Paisaje
    let sky: [Color]
    let farMountains: Color
    let nearMountains: Color
    let trees: Color
    let ground: Color
    let cloudOpacity: Double

    static let blue = StoryTheme(
        accent: Color(hex: 0x1565C0),
        deep: Color(hex: 0x0D3B8E),
        pale: Color(hex: 0xC9E5FF),
        chip: Color(hex: 0xE8F4FF),
        sky: [Color(hex: 0x2E9FFF), Color(hex: 0x4DB5FF), Color(hex: 0x7CCBFF)],
        farMountains: Color(hex: 0x5AAEF5),
        nearMountains: Color(hex: 0x3F93E8),
        trees: Color(hex: 0x2A78CC),
        ground: Color(hex: 0xA9D679),
        cloudOpacity: 0.85
    )

    static let red = StoryTheme(
        accent: Color(hex: 0xC62835),
        deep: Color(hex: 0x8E1B26),
        pale: Color(hex: 0xFFD5DA),
        chip: Color(hex: 0xFFF1F2),
        sky: [Color(hex: 0xFF6A70), Color(hex: 0xFF5A62), Color(hex: 0xFF7A7F)],
        farMountains: Color(hex: 0xE8545C),
        nearMountains: Color(hex: 0xD63C46),
        trees: Color(hex: 0xB82A35),
        ground: Color(hex: 0xC8303A),
        cloudOpacity: 0.40
    )

    /// Jugador 1, 3... = azul. Jugador 2, 4... = rojo.
    static func forPlayer(_ index: Int) -> StoryTheme {
        index.isMultiple(of: 2) ? .blue : .red
    }
}

// MARK: - Fondo a pantalla completa

/// Dibuja las dos escenas una encima de la otra y cambia entre ellas con un fundido suave
/// (sin animación si el usuario activó "Reducir movimiento").
struct StorySceneBackground: View {
    let playerIndex: Int
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var showsFirst: Bool { playerIndex.isMultiple(of: 2) }

    var body: some View {
        ZStack {
            StoryScene(theme: .blue).opacity(showsFirst ? 1 : 0)
            StoryScene(theme: .red).opacity(showsFirst ? 0 : 1)
        }
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.5), value: showsFirst)
        .ignoresSafeArea()
        .accessibilityHidden(true) // decorativo
    }
}

private struct StoryScene: View {
    let theme: StoryTheme

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height

            ZStack {
                LinearGradient(colors: theme.sky, startPoint: .top, endPoint: .bottom)

                // Nubes
                cloud(x: 0.80, y: 0.07, width: 0.20, in: geo.size)
                cloud(x: 0.03, y: 0.24, width: 0.14, in: geo.size)
                cloud(x: 0.95, y: 0.21, width: 0.12, in: geo.size)

                // Montañas lejanas y cercanas
                MountainRange(peaks: [
                    .init(x: 0.10, rise: 0.78, half: 0.20),
                    .init(x: 0.42, rise: 1.00, half: 0.26),
                    .init(x: 0.75, rise: 0.70, half: 0.22),
                    .init(x: 1.00, rise: 0.60, half: 0.18)
                ])
                .softFill(theme.farMountains)
                .frame(width: w, height: h * 0.42)
                .position(x: w / 2, y: h * 0.80 - h * 0.21)

                MountainRange(peaks: [
                    .init(x: 0.02, rise: 0.60, half: 0.18),
                    .init(x: 0.30, rise: 0.85, half: 0.22),
                    .init(x: 0.62, rise: 0.55, half: 0.20),
                    .init(x: 0.92, rise: 0.80, half: 0.24)
                ])
                .softFill(theme.nearMountains)
                .frame(width: w, height: h * 0.32)
                .position(x: w / 2, y: h * 0.86 - h * 0.16)

                // Árboles
                tree(x: 0.04, base: 0.82, width: 0.075, in: geo.size)
                tree(x: 0.10, base: 0.86, width: 0.095, in: geo.size)
                tree(x: 0.17, base: 0.84, width: 0.06, in: geo.size)
                tree(x: 0.89, base: 0.80, width: 0.085, in: geo.size)
                tree(x: 0.96, base: 0.86, width: 0.105, in: geo.size)

                // Colinas del frente
                HillShape()
                    .fill(theme.ground.opacity(0.75))
                    .frame(width: w, height: h * 0.20)
                    .position(x: w / 2, y: h - h * 0.10 - h * 0.03)
                HillShape()
                    .fill(theme.ground)
                    .frame(width: w, height: h * 0.18)
                    .scaleEffect(x: -1, y: 1)
                    .position(x: w / 2, y: h - h * 0.09)
            }
        }
    }

    private func cloud(x: CGFloat, y: CGFloat, width: CGFloat, in size: CGSize) -> some View {
        CloudShape()
            .fill(Color.white.opacity(theme.cloudOpacity))
            .frame(width: size.width * width, height: size.width * width * 0.5)
            .position(x: size.width * x, y: size.height * y)
    }

    private func tree(x: CGFloat, base: CGFloat, width: CGFloat, in size: CGSize) -> some View {
        let treeWidth = size.width * width
        let treeHeight = treeWidth * 1.6
        return PineTree()
            .softFill(theme.trees, radius: 4)
            .frame(width: treeWidth, height: treeHeight)
            .position(x: size.width * x, y: size.height * base - treeHeight / 2)
    }
}

// MARK: - Formas

private extension Shape {
    /// Relleno con las esquinas redondeadas (rellena y repasa el borde con el mismo color).
    func softFill(_ color: Color, radius: CGFloat = 10) -> some View {
        ZStack {
            self.fill(color)
            self.stroke(color, style: StrokeStyle(lineWidth: radius * 2, lineJoin: .round))
        }
    }
}

struct MountainRange: Shape {
    /// Todos los valores son fracciones del rectángulo.
    struct Peak {
        let x: CGFloat
        let rise: CGFloat
        let half: CGFloat
    }
    let peaks: [Peak]

    func path(in r: CGRect) -> Path {
        var p = Path()
        for peak in peaks {
            let tip = CGPoint(x: r.minX + r.width * peak.x, y: r.maxY - r.height * peak.rise)
            p.move(to: CGPoint(x: tip.x - r.width * peak.half, y: r.maxY))
            p.addLine(to: tip)
            p.addLine(to: CGPoint(x: tip.x + r.width * peak.half, y: r.maxY))
            p.closeSubpath()
        }
        return p
    }
}

struct PineTree: Shape {
    func path(in r: CGRect) -> Path {
        var p = Path()

        // Tronco
        let trunkWidth = r.width * 0.16
        let trunkTop = r.maxY - r.height * 0.14
        p.addRect(CGRect(x: r.midX - trunkWidth / 2, y: trunkTop,
                         width: trunkWidth, height: r.maxY - trunkTop))

        // Tres niveles de ramas
        let tiers: [(top: CGFloat, bottom: CGFloat, half: CGFloat)] = [
            (0.00, 0.42, 0.28),
            (0.22, 0.68, 0.38),
            (0.45, 0.88, 0.50)
        ]
        for tier in tiers {
            p.move(to: CGPoint(x: r.midX, y: r.minY + r.height * tier.top))
            p.addLine(to: CGPoint(x: r.midX + r.width * tier.half, y: r.minY + r.height * tier.bottom))
            p.addLine(to: CGPoint(x: r.midX - r.width * tier.half, y: r.minY + r.height * tier.bottom))
            p.closeSubpath()
        }
        return p
    }
}

struct CloudShape: Shape {
    func path(in r: CGRect) -> Path {
        var p = Path()
        let h = r.height
        p.addRoundedRect(in: CGRect(x: r.minX, y: r.minY + h * 0.45, width: r.width, height: h * 0.55),
                         cornerSize: CGSize(width: h * 0.275, height: h * 0.275))
        p.addEllipse(in: CGRect(x: r.minX + r.width * 0.12, y: r.minY + h * 0.18,
                                width: r.width * 0.34, height: h * 0.62))
        p.addEllipse(in: CGRect(x: r.minX + r.width * 0.36, y: r.minY,
                                width: r.width * 0.38, height: h * 0.80))
        p.addEllipse(in: CGRect(x: r.minX + r.width * 0.62, y: r.minY + h * 0.25,
                                width: r.width * 0.28, height: h * 0.55))
        return p
    }
}

struct HillShape: Shape {
    func path(in r: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: r.minX, y: r.maxY))
        p.addLine(to: CGPoint(x: r.minX, y: r.minY + r.height * 0.55))
        p.addCurve(to: CGPoint(x: r.maxX, y: r.minY + r.height * 0.30),
                   control1: CGPoint(x: r.minX + r.width * 0.30, y: r.minY - r.height * 0.10),
                   control2: CGPoint(x: r.minX + r.width * 0.70, y: r.minY + r.height * 0.80))
        p.addLine(to: CGPoint(x: r.maxX, y: r.maxY))
        p.closeSubpath()
        return p
    }
}

// MARK: - Detalles decorativos

/// Tres rayitos amarillos, como los del título y la tarjeta del personaje.
struct Sparkle: View {
    var body: some View {
        ZStack {
            ray(width: 26, angle: -28, y: -15)
            ray(width: 30, angle: 4, y: 0)
            ray(width: 26, angle: 30, y: 15)
        }
        .frame(width: 44, height: 44)
        .accessibilityHidden(true)
    }

    private func ray(width: CGFloat, angle: Double, y: CGFloat) -> some View {
        Capsule()
            .fill(Color(hex: 0xFFD93D))
            .frame(width: width, height: 9)
            .rotationEffect(.degrees(angle))
            .offset(x: -6, y: y)
    }
}

/// Estrellitas suaves para el fondo de la tarjeta del personaje.
struct CardStars: View {
    let color: Color

    private let spots: [(x: CGFloat, y: CGFloat, size: CGFloat, angle: Double)] = [
        (0.20, 0.10, 26, -12), (0.62, 0.07, 34, 10), (0.87, 0.20, 24, -8),
        (0.10, 0.48, 22, 15), (0.90, 0.60, 28, -10), (0.28, 0.80, 24, 8)
    ]

    var body: some View {
        GeometryReader { geo in
            ForEach(spots.indices, id: \.self) { i in
                Image(systemName: "star.fill")
                    .font(.system(size: spots[i].size))
                    .foregroundStyle(color)
                    .rotationEffect(.degrees(spots[i].angle))
                    .position(x: geo.size.width * spots[i].x, y: geo.size.height * spots[i].y)
            }
        }
        .accessibilityHidden(true)
    }
}
