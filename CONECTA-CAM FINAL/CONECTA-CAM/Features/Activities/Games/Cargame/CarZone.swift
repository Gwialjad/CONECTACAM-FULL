//
//  CarZone.swift
//  Conecta CAM
//
//  Las zonas de la carrera: colores, estilo del paisaje y el "guion" de obstáculos.
//
//  Cada zona es un tramo de CarLevel.zoneLength puntos. El guion es una lista de
//  pasos: cada paso dice cuánto camino libre hay ANTES del obstáculo ("gap") y qué
//  obstáculo viene. CarLevel convierte los guiones en posiciones reales.
//
//  Para cambiar la dificultad de una zona solo hay que editar su lista `steps`.
//

import SwiftUI

// MARK: - Colores que se pueden mezclar

/// Un color RGB que se puede mezclar con otro (para el cambio suave entre zonas).
struct CarRGB {
    let r: Double
    let g: Double
    let b: Double

    init(_ hex: UInt32) {
        r = Double((hex >> 16) & 0xFF) / 255
        g = Double((hex >> 8) & 0xFF) / 255
        b = Double(hex & 0xFF) / 255
    }

    private init(r: Double, g: Double, b: Double) {
        self.r = r
        self.g = g
        self.b = b
    }

    func mixed(with other: CarRGB, amount t: Double) -> CarRGB {
        CarRGB(r: r + (other.r - r) * t,
               g: g + (other.g - g) * t,
               b: b + (other.b - b) * t)
    }

    func darker(_ amount: Double) -> CarRGB { mixed(with: CarRGB(0x000000), amount: amount) }
    func lighter(_ amount: Double) -> CarRGB { mixed(with: CarRGB(0xFFFFFF), amount: amount) }

    var color: Color { Color(red: r, green: g, blue: b) }
}

struct CarPalette {
    let skyTop: CarRGB
    let skyBottom: CarRGB
    let farMountains: CarRGB
    let hills: CarRGB
    let trees: CarRGB
    let ground: CarRGB
    let groundTop: CarRGB
    let cloud: CarRGB

    func mixed(with o: CarPalette, amount t: Double) -> CarPalette {
        CarPalette(
            skyTop: skyTop.mixed(with: o.skyTop, amount: t),
            skyBottom: skyBottom.mixed(with: o.skyBottom, amount: t),
            farMountains: farMountains.mixed(with: o.farMountains, amount: t),
            hills: hills.mixed(with: o.hills, amount: t),
            trees: trees.mixed(with: o.trees, amount: t),
            ground: ground.mixed(with: o.ground, amount: t),
            groundTop: groundTop.mixed(with: o.groundTop, amount: t),
            cloud: cloud.mixed(with: o.cloud, amount: t)
        )
    }
}

// MARK: - Pasos del guion

enum CarStep {
    /// Un obstáculo sólido (pinchos, piedra, tronco, cactus, hielo) tras `gap` puntos de camino libre.
    case obstacle(CarHazardKind, gap: CGFloat)
    /// Un agujero en el camino. Cae el carro si va por el suelo.
    case pit(width: CGFloat, gap: CGFloat)
    /// Un charco (lodo, arena, nieve): no hace daño pero frena el carro.
    case mud(gap: CGFloat)
    /// Una fila de estrellas en el camino (premio por avanzar).
    case stars(gap: CGFloat)
}

enum CarZoneStyle {
    case meadow, desert, forest, snow
}

// MARK: - Zonas

struct CarZone {
    let name: String
    let style: CarZoneStyle
    let palette: CarPalette
    let steps: [CarStep]

    // 1. Pradera: para entrar en calor. Pocos obstáculos y mucho espacio.
    static let meadow = CarZone(
        name: "Pradera",
        style: .meadow,
        palette: CarPalette(
            skyTop: CarRGB(0x54C8F5), skyBottom: CarRGB(0xB5ECFF),
            farMountains: CarRGB(0x72BCEB), hills: CarRGB(0x86D062),
            trees: CarRGB(0x2E9B4B), ground: CarRGB(0x6BCB4F),
            groundTop: CarRGB(0x8FE06E), cloud: CarRGB(0xFFFFFF)
        ),
        steps: [
            .stars(gap: 120),
            .obstacle(.spikes, gap: 400),
            .obstacle(.rock, gap: 440),
            .pit(width: 120, gap: 420),
            .obstacle(.spikes, gap: 420),
            .mud(gap: 380),
            .obstacle(.rock, gap: 560),
            .obstacle(.spikes, gap: 400),
            .obstacle(.rock, gap: 380),
            .pit(width: 130, gap: 420)
        ]
    )

    // 2. Desierto: cactus altos y agujeros un poco más anchos.
    static let desert = CarZone(
        name: "Desierto",
        style: .desert,
        palette: CarPalette(
            skyTop: CarRGB(0xFF9F5A), skyBottom: CarRGB(0xFFE3A8),
            farMountains: CarRGB(0xE59A5C), hills: CarRGB(0xF2C76E),
            trees: CarRGB(0x5BA24A), ground: CarRGB(0xE9C46A),
            groundTop: CarRGB(0xF6DA8C), cloud: CarRGB(0xFFF3DC)
        ),
        steps: [
            .obstacle(.cactus, gap: 400),
            .obstacle(.cactus, gap: 360),
            .pit(width: 140, gap: 400),
            .obstacle(.spikes, gap: 380),
            .mud(gap: 380),
            .obstacle(.cactus, gap: 540),
            .obstacle(.rock, gap: 360),
            .obstacle(.cactus, gap: 360),
            .pit(width: 150, gap: 380),
            .obstacle(.cactus, gap: 360),
            .obstacle(.spikes, gap: 340)
        ]
    )

    // 3. Bosque: troncos largos y obstáculos más seguidos.
    static let forest = CarZone(
        name: "Bosque",
        style: .forest,
        palette: CarPalette(
            skyTop: CarRGB(0x6C7BE0), skyBottom: CarRGB(0xC4B5F5),
            farMountains: CarRGB(0x8E8AD8), hills: CarRGB(0x4E9E6B),
            trees: CarRGB(0x1F6B4A), ground: CarRGB(0x3E9B58),
            groundTop: CarRGB(0x5CBA6E), cloud: CarRGB(0xF3EDFF)
        ),
        steps: [
            .obstacle(.log, gap: 400),
            .obstacle(.rock, gap: 360),
            .pit(width: 150, gap: 380),
            .obstacle(.log, gap: 340),
            .obstacle(.spikes, gap: 320),
            .mud(gap: 340),
            .obstacle(.log, gap: 520),
            .obstacle(.spikes, gap: 340),
            .pit(width: 160, gap: 360),
            .obstacle(.rock, gap: 330),
            .obstacle(.spikes, gap: 320)
        ]
    )

    // 4. Nieve: la más difícil, con bloques de hielo y los agujeros más anchos.
    static let snow = CarZone(
        name: "Nieve",
        style: .snow,
        palette: CarPalette(
            skyTop: CarRGB(0x8EC9F2), skyBottom: CarRGB(0xEAF6FF),
            farMountains: CarRGB(0xB8D8F0), hills: CarRGB(0xDDEFFB),
            trees: CarRGB(0x4F8FB5), ground: CarRGB(0xCFE6F5),
            groundTop: CarRGB(0xFFFFFF), cloud: CarRGB(0xFFFFFF)
        ),
        steps: [
            .obstacle(.ice, gap: 380),
            .obstacle(.spikes, gap: 340),
            .pit(width: 160, gap: 360),
            .obstacle(.ice, gap: 320),
            .mud(gap: 330),
            .obstacle(.ice, gap: 520),
            .obstacle(.spikes, gap: 320),
            .obstacle(.ice, gap: 320),
            .pit(width: 170, gap: 340),
            .obstacle(.ice, gap: 310),
            .obstacle(.spikes, gap: 300),
            .pit(width: 160, gap: 300)
        ]
    )
}
