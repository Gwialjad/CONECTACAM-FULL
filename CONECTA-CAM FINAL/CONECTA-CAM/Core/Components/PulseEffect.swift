//
//  PulseEffect.swift
//  Conecta CAM
//

import SwiftUI

/// Hace que una vista "respire": pasa lento de grande a pequeño y de vuelta, sin parar.
/// Si el iPad tiene activado "Reducir movimiento", la vista se queda quieta.
struct PulseEffect: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    var delay: Double = 0
    @State private var big = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(reduceMotion ? 1 : (big ? 1.08 : 0.94))
            .onAppear {
                guard !reduceMotion else { return }
                withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true).delay(delay)) {
                    big = true
                }
            }
    }
}

extension View {
    /// `delay` desfasa la animación para que varios íconos no latan al mismo tiempo.
    func pulse(delay: Double = 0) -> some View {
        modifier(PulseEffect(delay: delay))
    }
}
