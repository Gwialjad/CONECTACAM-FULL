//
//  RoundedPolygon.swift
//  Conecta CAM
//

import SwiftUI

/// Polígono con esquinas redondeadas. Los puntos van en proporción (0...1) del área donde se dibuja.
struct RoundedPolygon: Shape {
    var points: [(CGFloat, CGFloat)]
    var radius: CGFloat

    func path(in r: CGRect) -> Path {
        let pts = points.map { CGPoint(x: r.minX + $0.0 * r.width, y: r.minY + $0.1 * r.height) }
        var p = Path()
        guard pts.count > 2 else { return p }
        let n = pts.count
        // Empieza a la mitad del último borde para que todas las esquinas queden redondeadas.
        p.move(to: CGPoint(x: (pts[n - 1].x + pts[0].x) / 2, y: (pts[n - 1].y + pts[0].y) / 2))
        for i in 0..<n {
            p.addArc(tangent1End: pts[i], tangent2End: pts[(i + 1) % n], radius: radius)
        }
        p.closeSubpath()
        return p
    }
}
