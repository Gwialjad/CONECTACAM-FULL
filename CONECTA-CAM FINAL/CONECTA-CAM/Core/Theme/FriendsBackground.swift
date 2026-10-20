//
//  FriendsBackground.swift
//  Conecta CAM
//

import SwiftUI

/// Fondo geométrico azul/turquesa de la pantalla de personajes.
struct FriendsBackground: View {
    var body: some View {
        GeometryReader { geo in
            let size = geo.size
            ZStack {
                LinearGradient(colors: [Color(hex: 0x4FC3F7), Color(hex: 0x8DF5EE)],
                               startPoint: .topLeading, endPoint: .bottomTrailing)
                // Gran polígono azul del centro
                polygon([(0.0, 0.20), (0.37, 0.0), (0.85, 0.0), (0.88, 0.13),
                         (0.62, 0.46), (0.46, 0.95), (0.06, 0.62)], in: size)
                    .fill(Color(hex: 0x3B82F6))
                // Facetas más claras / oscuras
                polygon([(0.0, 0.20), (0.06, 0.62), (0.0, 0.80)], in: size)
                    .fill(Color(hex: 0x2F74EE))
                polygon([(0.85, 0.0), (1.0, 0.0), (1.0, 0.15), (0.88, 0.13)], in: size)
                    .fill(Color(hex: 0x6FDDF7))
                polygon([(0.88, 0.13), (1.0, 0.15), (1.0, 0.55), (0.62, 0.46)], in: size)
                    .fill(Color(hex: 0x4FB4FA))
                polygon([(0.0, 0.62), (0.06, 0.62), (0.46, 0.95), (0.5, 1.0), (0.0, 1.0)], in: size)
                    .fill(Color(hex: 0x6BEBF0))
                polygon([(1.0, 0.65), (1.0, 1.0), (0.78, 1.0)], in: size)
                    .fill(Color(hex: 0x62E6EE))
            }
        }
        .ignoresSafeArea()
        .accessibilityHidden(true) // decorativo
    }

    /// Dibuja un polígono con puntos en proporción (0...1) del tamaño de la pantalla.
    private func polygon(_ pts: [(CGFloat, CGFloat)], in size: CGSize) -> Path {
        var p = Path()
        guard let first = pts.first else { return p }
        p.move(to: CGPoint(x: first.0 * size.width, y: first.1 * size.height))
        for pt in pts.dropFirst() {
            p.addLine(to: CGPoint(x: pt.0 * size.width, y: pt.1 * size.height))
        }
        p.closeSubpath()
        return p
    }
}
