//
//  SunnyBackground.swift
//  Conecta CAM
//

import SwiftUI

/// Fondo amarillo soleado con ondas suaves, estrellas y nubes.
struct SunnyBackground: View {
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            ZStack {
                LinearGradient(colors: [Color(hex: 0xFFD23F), Color(hex: 0xFFE470)],
                               startPoint: .top, endPoint: .bottom)
                // Ondas suaves
                Path { p in
                    p.move(to: CGPoint(x: 0, y: h * 0.35))
                    p.addCurve(to: CGPoint(x: w, y: h * 0.15),
                               control1: CGPoint(x: w * 0.35, y: h * 0.10),
                               control2: CGPoint(x: w * 0.65, y: h * 0.45))
                    p.addLine(to: CGPoint(x: w, y: 0))
                    p.addLine(to: CGPoint(x: 0, y: 0))
                    p.closeSubpath()
                }
                .fill(Color.white.opacity(0.12))
                Path { p in
                    p.move(to: CGPoint(x: 0, y: h * 0.85))
                    p.addCurve(to: CGPoint(x: w, y: h * 0.70),
                               control1: CGPoint(x: w * 0.4, y: h * 0.65),
                               control2: CGPoint(x: w * 0.7, y: h * 0.95))
                    p.addLine(to: CGPoint(x: w, y: h))
                    p.addLine(to: CGPoint(x: 0, y: h))
                    p.closeSubpath()
                }
                .fill(Color(hex: 0xFFB300).opacity(0.18))

                // Estrellas decorativas
                star(size: 74, angle: 14).position(x: w * 0.74, y: h * 0.11)
                star(size: 62, angle: -10).position(x: w * 0.15, y: h * 0.94)

                // Nubes
                cloud(w * 0.04, h * 1.0, w * 0.22, h * 0.20)
                cloud(w * 0.96, h * 1.0, w * 0.26, h * 0.22)
            }
        }
        .ignoresSafeArea()
        .accessibilityHidden(true) // decorativo
    }

    private func star(size: CGFloat, angle: Double) -> some View {
        Image(systemName: "star.fill")
            .font(.system(size: size))
            .foregroundStyle(Color(hex: 0xFFC82E))
            .shadow(color: Color(hex: 0xE59A00).opacity(0.5), radius: 4, y: 4)
            .rotationEffect(.degrees(angle))
    }

    private func cloud(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat) -> some View {
        Ellipse()
            .fill(Color(hex: 0xFFF6E8).opacity(0.95))
            .frame(width: width, height: height)
            .blur(radius: 10)
            .position(x: x, y: y)
    }
}
