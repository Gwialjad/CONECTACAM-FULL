//
//  CarStyle.swift
//  Conecta CAM
//
//  Colores, ayudas de accesibilidad y botones compartidos de la carrera.
//  Jugador 1 = azul, jugador 2 = rojo (igual que en "Historia en cadena").
//

import SwiftUI

enum CarStyle {
    /// Texto oscuro para botones verdes y amarillos (contraste ≥ 8:1).
    static let ink = Color(hex: 0x1F2937)
    static let heart = Color(hex: 0xE53935)
    static let starYellow = Color(hex: 0xFFD93D)

    /// Color fuerte del jugador (texto blanco encima: contraste ≥ 5.5:1).
    static func accent(_ playerIndex: Int) -> Color {
        playerIndex == 0 ? Color(hex: 0x1565C0) : Color(hex: 0xC62835)
    }
    /// Color muy oscuro del jugador, para texto sobre blanco.
    static func deep(_ playerIndex: Int) -> Color {
        playerIndex == 0 ? Color(hex: 0x0D3B8E) : Color(hex: 0x8E1B26)
    }
    static func pale(_ playerIndex: Int) -> Color {
        playerIndex == 0 ? Color(hex: 0xC9E5FF) : Color(hex: 0xFFD5DA)
    }
}

/// Ayudas que se pueden activar al empezar o en la pausa (se recuerdan entre partidas).
struct CarAssist {
    /// Un toque para empezar a acelerar y otro para parar, en vez de mantener apretado.
    var tapToAccelerate = false
    /// El carro salta solo antes de cada obstáculo.
    var autoJump = false

    static let tapKey = "conectacam.car.tapToAccelerate"
    static let autoJumpKey = "conectacam.car.autoJump"
}

/// Los botones "se hunden" un poco al tocarlos (sin movimiento si se activó "Reducir movimiento").
struct CarPressableStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed && !reduceMotion ? 0.95 : 1)
            .animation(reduceMotion ? nil : .easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

/// Botón redondo con un ícono (salir, pausa).
struct CarIconButton: View {
    let systemName: String
    let label: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 24, weight: .heavy))
                .foregroundStyle(.white)
                .frame(width: 58, height: 58)
                .background(color, in: Circle())
                .overlay(Circle().stroke(.white, lineWidth: 4))
        }
        .buttonStyle(CarPressableStyle())
        .accessibilityLabel(label)
    }
}

/// Botón grande de las tarjetas (EMPEZAR, SEGUIR, CONTINUAR).
struct CarPrimaryButton: View {
    let title: String
    let systemImage: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: systemImage)
                    .font(.system(size: 26, weight: .heavy))
                Text(title)
                    .camFont(30, .heavy)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .foregroundStyle(CarStyle.ink)
            .padding(.horizontal, 34)
            .frame(minHeight: 70)
            .frame(maxWidth: .infinity)
            .background(color, in: Capsule())
            .overlay(Capsule().stroke(.white.opacity(0.85), lineWidth: 4))
        }
        .buttonStyle(CarPressableStyle())
    }
}
