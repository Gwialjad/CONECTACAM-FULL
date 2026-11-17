//
//  StoryControls.swift
//  Conecta CAM
//
//  Botones y estilos compartidos de "Historia en cadena".
//

import SwiftUI

enum StoryStyle {
    /// Texto oscuro para los botones verdes y amarillos (contraste ≥ 8:1).
    static let ink = Color(hex: 0x1F2937)
}

/// Los botones "se hunden" un poco al tocarlos (sin movimiento si se activó "Reducir movimiento").
struct StoryPressableStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed && !reduceMotion ? 0.96 : 1)
            .animation(reduceMotion ? nil : .easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

/// "TERMINAR": se activa cuando cada jugador ya agregó una frase.
struct StoryFinishButton: View {
    let isEnabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: "flag.checkered")
                Text("TERMINAR").camFont(24, .heavy)
            }
            .foregroundStyle(StoryStyle.ink)
            .lineLimit(1)
            .minimumScaleFactor(0.7)
            .frame(maxWidth: .infinity, minHeight: 60)
            .background(Color.camYellow, in: Capsule())
            .overlay(Capsule().stroke(.white.opacity(0.8), lineWidth: 3))
        }
        .buttonStyle(StoryPressableStyle())
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1 : 0.5)
        .accessibilityLabel("Terminar historia")
        .accessibilityHint(isEnabled
            ? "Finaliza la actividad"
            : "Se activa cuando cada jugador haya agregado una frase")
    }
}

/// La "X": si ya hay algo escrito pregunta antes de salir.
struct StoryExitButton: View {
    let theme: StoryTheme
    @Binding var confirming: Bool
    /// Se llama al tocar la X (el juego decide si salir ya o preguntar).
    let onRequest: () -> Void
    /// Se llama si confirman que quieren salir.
    let onLeave: () -> Void

    var body: some View {
        Button(action: onRequest) {
            Image(systemName: "xmark")
                .font(.system(size: 24, weight: .heavy))
                .foregroundStyle(.white)
                .frame(width: 58, height: 58)
                .background(theme.accent, in: Circle())
                .overlay(Circle().stroke(.white, lineWidth: 4))
        }
        .buttonStyle(StoryPressableStyle())
        .accessibilityLabel("Salir del juego")
        .confirmationDialog("¿Salir del juego?", isPresented: $confirming, titleVisibility: .visible) {
            Button("Salir sin terminar", role: .destructive) { onLeave() }
            Button("Seguir jugando", role: .cancel) {}
        } message: {
            Text("La historia no se guardará.")
        }
    }
}
