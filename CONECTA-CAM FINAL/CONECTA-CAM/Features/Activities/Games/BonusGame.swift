//
//  BonusGame.swift
//  Conecta CAM
//

import SwiftUI

// Juego 3 (provisional): ocupa el lugar de TeamHoldGame.
// Se desbloquea cuando se cumplen todas las metas (ver AppStore.goalsComplete).
// Aquí irá el juego real; por ahora solo muestra un aviso.
struct BonusGame: View {
    let players: [String]
    let onFinish: () -> Void   // llamar cuando el juego termine (guarda la sesión y muestra "¡Lo lograron juntos!")

    var body: some View {
        VStack(spacing: 20) {
            Text("¡Próximamente!")
                .camFont(52, .heavy)
                .foregroundStyle(.white)
                .accessibilityAddTraits(.isHeader)
            Text("Este juego todavía se está preparando.")
                .camFont(28)
                .foregroundStyle(.white.opacity(0.9))
                .multilineTextAlignment(.center)
        }
        .padding(40)
    }
}
