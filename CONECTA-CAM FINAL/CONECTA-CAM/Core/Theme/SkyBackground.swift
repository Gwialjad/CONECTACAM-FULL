//
//  SkyBackground.swift
//  Conecta CAM
//

import SwiftUI

/// Cielo azul con nubes suaves para el menú principal.
struct SkyBackground: View {
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            ZStack {
                LinearGradient(colors: [Color(hex: 0x3A94EE), Color(hex: 0x6CC6FA), Color(hex: 0x9ADFFF)],
                               startPoint: .top, endPoint: .bottom)
                // Rayos de luz suaves
                Path { p in
                    p.move(to: CGPoint(x: w * 0.0, y: h * 0.0))
                    p.addLine(to: CGPoint(x: w * 0.22, y: h * 0.0))
                    p.addLine(to: CGPoint(x: w * 0.0, y: h * 0.45))
                    p.closeSubpath()
                }
                .fill(Color.white.opacity(0.10))
                Path { p in
                    p.move(to: CGPoint(x: w * 1.0, y: h * 0.0))
                    p.addLine(to: CGPoint(x: w * 0.8, y: h * 0.0))
                    p.addLine(to: CGPoint(x: w * 1.0, y: h * 0.5))
                    p.closeSubpath()
                }
                .fill(Color.white.opacity(0.10))
                // Nubes
                cloud(w * 0.12, h * 0.96, w * 0.26, h * 0.20)
                cloud(w * 0.03, h * 0.88, w * 0.16, h * 0.14)
                cloud(w * 0.92, h * 0.62, w * 0.22, h * 0.16)
                cloud(w * 0.99, h * 0.70, w * 0.14, h * 0.12)
            }
        }
        .ignoresSafeArea()
        .accessibilityHidden(true) // decorativo
    }

    private func cloud(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat) -> some View {
        Ellipse()
            .fill(Color.white.opacity(0.55))
            .frame(width: width, height: height)
            .blur(radius: 14)
            .position(x: x, y: y)
    }
}
