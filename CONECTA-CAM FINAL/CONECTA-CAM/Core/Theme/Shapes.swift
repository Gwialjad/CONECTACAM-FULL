//
//  Shapes.swift
//  Conecta CAM
//

import SwiftUI

struct WaveShape: Shape {
    func path(in r: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: r.minX, y: r.midY))
        p.addCurve(to: CGPoint(x: r.maxX, y: r.midY),
                   control1: CGPoint(x: r.width * 0.3, y: r.minY - r.height * 0.3),
                   control2: CGPoint(x: r.width * 0.7, y: r.maxY + r.height * 0.3))
        p.addLine(to: CGPoint(x: r.maxX, y: r.maxY))
        p.addLine(to: CGPoint(x: r.minX, y: r.maxY))
        p.closeSubpath()
        return p
    }
}

struct RibbonShape: Shape {
    func path(in r: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: r.minX, y: r.height * 0.25))
        p.addCurve(to: CGPoint(x: r.maxX, y: 0),
                   control1: CGPoint(x: r.width * 0.3, y: r.height * 0.7),
                   control2: CGPoint(x: r.width * 0.65, y: r.height * 0.1))
        p.addLine(to: CGPoint(x: r.maxX, y: r.height * 0.75))
        p.addCurve(to: CGPoint(x: r.minX, y: r.height),
                   control1: CGPoint(x: r.width * 0.65, y: r.height * 0.45),
                   control2: CGPoint(x: r.width * 0.3, y: r.height * 1.0))
        p.closeSubpath()
        return p
    }
}
