//
//  AnimatedFlagBackground.swift
//  Conecta CAM
//

import SwiftUI

/// Fondo animado: la bandera ondeando en la cima (32 imágenes flag_00 ... flag_31 en Assets).
/// Respeta "Reducir movimiento" de iOS: en ese caso muestra una sola imagen fija.
struct AnimatedFlagBackground: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    private let frameCount = 32
    private let fps = 20.0   // velocidad de la animación

    var body: some View {
        GeometryReader { geo in
            TimelineView(.periodic(from: .now, by: 1 / fps)) { context in
                let index = reduceMotion
                    ? 0
                    : Int(context.date.timeIntervalSinceReferenceDate * fps) % frameCount
                Image("flag_\(String(format: "%02d", index))")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geo.size.width, height: geo.size.height)
                    .clipped()
            }
        }
        .ignoresSafeArea()
        .accessibilityHidden(true) // decorativo
    }
}

//I added this new Folder for an animated background