//
//  CarLevel.swift
//  Conecta CAM
//
//  El nivel completo: obstáculos, estrellas y puntos de control.
//  Todo se calcula una sola vez a partir de los guiones de CarZone.swift,
//  y es siempre igual, así que los niños pueden aprender el camino.
//
//  Las posiciones son puntos del mundo: x crece hacia la derecha y
//  las alturas se miden hacia arriba desde el suelo.
//

import SwiftUI

// MARK: - Obstáculos

enum CarHazardKind: Hashable {
    case spikes   // pinchos: daño
    case rock     // piedra: daño
    case log      // tronco: daño
    case cactus   // cactus alto: daño
    case ice      // bloque de hielo: daño
    case pit      // agujero: se cae y pierde una vida
    case slow     // charco: frena, no hace daño

    /// Tamaño en puntos. El agujero usa un ancho de ejemplo (cada uno trae el suyo).
    var size: (width: CGFloat, height: CGFloat) {
        switch self {
        case .spikes: return (84, 32)
        case .rock:   return (72, 52)
        case .log:    return (100, 36)
        case .cactus: return (40, 84)
        case .ice:    return (70, 60)
        case .pit:    return (140, 0)
        case .slow:   return (220, 0)
        }
    }

    /// Los obstáculos sólidos hacen daño si el carro los toca.
    var isSolid: Bool { self != .pit && self != .slow }
}

struct CarHazard: Identifiable {
    let id: Int
    let kind: CarHazardKind
    let x: CGFloat        // borde izquierdo
    let width: CGFloat
    let height: CGFloat   // 0 en agujeros y charcos

    var maxX: CGFloat { x + width }
    var midX: CGFloat { x + width / 2 }
    var isSolid: Bool { kind.isSolid }
}

struct CarStar: Identifiable {
    let id: Int
    let x: CGFloat
    let y: CGFloat        // altura sobre el suelo
}

// MARK: - Nivel

struct CarLevel {
    /// Largo de cada zona. Con 4 zonas el nivel mide 26 000 puntos
    /// (a velocidad normal, casi un minuto y medio sin parar).
    static let zoneLength: CGFloat = 6500
    /// Camino libre al empezar cada zona.
    static let startTail: CGFloat = 520
    /// Camino libre antes de cada punto de control.
    static let endTail: CGFloat = 450

    let zones: [CarZone]
    let hazards: [CarHazard]   // ordenados por x
    let stars: [CarStar]       // ordenadas por x

    var length: CGFloat { Self.zoneLength * CGFloat(zones.count) }

    /// Un punto de control al final de cada zona (menos la última).
    var checkpoints: [CGFloat] {
        guard zones.count > 1 else { return [] }
        return (1..<zones.count).map { CGFloat($0) * Self.zoneLength }
    }

    func zoneIndex(at x: CGFloat) -> Int {
        min(max(Int(x / Self.zoneLength), 0), zones.count - 1)
    }

    /// Colores en esa posición. En el último tramo de cada zona se mezclan
    /// con los de la siguiente para que el cambio sea suave.
    func palette(at x: CGFloat) -> CarPalette {
        let i = zoneIndex(at: x)
        let frac = x / Self.zoneLength - CGFloat(i)
        guard i < zones.count - 1, frac > 0.9 else { return zones[i].palette }
        return zones[i].palette.mixed(with: zones[i + 1].palette, amount: Double((frac - 0.9) / 0.1))
    }

    // MARK: Construcción

    init(zones: [CarZone]) {
        var hazards: [CarHazard] = []
        var stars: [CarStar] = []
        var cursor: CGFloat = 0
        var limit: CGFloat = 0

        func addArc(centerX: CGFloat) {
            // Cinco estrellas en arco: muestran por dónde pasa un buen salto.
            for k in -2...2 {
                let dx = CGFloat(k) * 60
                let y = 125 - 75 * (dx / 120) * (dx / 120)
                stars.append(CarStar(id: 0, x: centerX + dx, y: y))
            }
        }

        func addHazard(_ kind: CarHazardKind, width: CGFloat, height: CGFloat, gap: CGFloat, arc: Bool) {
            let x = cursor + gap
            guard x + width <= limit else { return } // no cabe: se omite
            hazards.append(CarHazard(id: hazards.count, kind: kind, x: x, width: width, height: height))
            if arc { addArc(centerX: x + width / 2) }
            cursor = x + width
        }

        for (index, zone) in zones.enumerated() {
            let zoneStart = CGFloat(index) * Self.zoneLength
            limit = zoneStart + Self.zoneLength - Self.endTail
            // La primera zona deja más espacio porque el carro arranca parado.
            cursor = zoneStart + Self.startTail + (index == 0 ? 250 : 0)

            for step in zone.steps {
                switch step {
                case .obstacle(let kind, let gap):
                    addHazard(kind, width: kind.size.width, height: kind.size.height, gap: gap, arc: true)
                case .pit(let width, let gap):
                    addHazard(.pit, width: width, height: 0, gap: gap, arc: true)
                case .mud(let gap):
                    addHazard(.slow, width: CarHazardKind.slow.size.width, height: 0, gap: gap, arc: false)
                case .stars(let gap):
                    let x0 = cursor + gap
                    guard x0 + 280 <= limit else { continue }
                    for k in 0..<5 {
                        stars.append(CarStar(id: 0, x: x0 + CGFloat(k) * 70, y: 42))
                    }
                    cursor = x0 + 280
                }
            }
        }

        stars.sort { $0.x < $1.x }
        self.zones = zones
        self.hazards = hazards
        self.stars = stars.enumerated().map { CarStar(id: $0.offset, x: $0.element.x, y: $0.element.y) }
    }

    static let standard = CarLevel(zones: [.meadow, .desert, .forest, .snow])
}
