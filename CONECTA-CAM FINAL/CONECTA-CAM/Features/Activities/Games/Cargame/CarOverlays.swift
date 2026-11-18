//
//  CarOverlays.swift
//  Conecta CAM
//
//  Las tarjetas que aparecen sobre el juego:
//    Inicio ("¡Carrera en equipo!"), Pausa, "¡Casi lo logran!" y "¡LO LOGRARON!".
//

import SwiftUI

struct CarOverlay: View {
    let engine: CarGameEngine
    let players: [String]
    let friends: [Friend]
    @Binding var tapToAccelerate: Bool
    @Binding var autoJump: Bool
    /// Salir del juego (el juego decide si pregunta antes).
    let onExit: () -> Void
    /// La carrera terminó: se registra la partida.
    let onFinish: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.5).ignoresSafeArea()

            ScrollView {
                card
                    .padding(30)
                    .frame(maxWidth: 700)
                    .frame(maxWidth: .infinity)
            }
            .scrollBounceBehavior(.basedOnSize)
        }
        .accessibilityElement(children: .contain)
        .accessibilityAddTraits(.isModal)
    }

    private func name(_ index: Int) -> String {
        players.indices.contains(index) ? players[index] : "Jugador \(index + 1)"
    }

    // MARK: Tarjeta

    @ViewBuilder
    private var card: some View {
        switch engine.phase {
        case .ready:      readyCard
        case .paused:     pausedCard
        case .outOfLives: outOfLivesCard
        case .won:        wonCard
        case .playing:    EmptyView()
        }
    }

    private func cardFrame<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        VStack(spacing: 20) {
            content()
        }
        .padding(30)
        .frame(maxWidth: .infinity)
        .background(.white, in: RoundedRectangle(cornerRadius: 36))
        .overlay(RoundedRectangle(cornerRadius: 36).stroke(CarStyle.pale(0), lineWidth: 8))
    }

    private func title(_ text: String) -> some View {
        Text(text)
            .camFont(40, .heavy)
            .foregroundStyle(CarStyle.deep(0))
            .multilineTextAlignment(.center)
            .minimumScaleFactor(0.7)
            .accessibilityAddTraits(.isHeader)
    }

    private func message(_ text: String) -> some View {
        Text(text)
            .camFont(24, .medium)
            .foregroundStyle(CarStyle.ink)
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
    }

    private func exitLink(_ text: String = "Salir del juego") -> some View {
        Button(action: onExit) {
            Text(text)
                .camFont(22, .bold)
                .foregroundStyle(CarStyle.deep(0))
                .frame(minHeight: 48)
                .padding(.horizontal, 16)
        }
        .buttonStyle(CarPressableStyle())
    }

    // MARK: Inicio

    private var readyCard: some View {
        cardFrame {
            title("¡Carrera en equipo!")
            message("Lleguen juntos a la meta. ¡Junten estrellas y cuiden sus corazones!")

            VStack(spacing: 12) {
                roleRow(0, symbol: "arrow.right", text: "\(name(0)) acelera")
                roleRow(1, symbol: "arrow.up", text: "\(name(1)) salta")
            }

            options

            CarPrimaryButton(title: "¡EMPEZAR!", systemImage: "flag.checkered", color: .camGreen) {
                Haptics.impact(.medium)
                engine.begin()
            }
            exitLink()
        }
    }

    private func roleRow(_ index: Int, symbol: String, text: String) -> some View {
        HStack(spacing: 14) {
            if friends.indices.contains(index) {
                Image(friends[index].imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 56, height: 56)
                    .accessibilityHidden(true)
            }
            Text(text)
                .camFont(26, .heavy)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
            Spacer(minLength: 8)
            Image(systemName: symbol)
                .font(.system(size: 28, weight: .heavy))
                .accessibilityHidden(true)
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 18)
        .padding(.vertical, 8)
        .background(CarStyle.accent(index), in: Capsule())
        .accessibilityElement(children: .combine)
    }

    // MARK: Ayudas

    private var options: some View {
        VStack(spacing: 14) {
            Toggle(isOn: $tapToAccelerate) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Acelerar con un toque").camFont(22, .bold)
                    Text("Un toque para avanzar y otro para parar, sin mantener apretado.")
                        .camFont(17)
                }
            }
            Toggle(isOn: $autoJump) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Saltos automáticos").camFont(22, .bold)
                    Text("El carro salta solo antes de cada obstáculo. El botón de saltar también funciona.")
                        .camFont(17)
                }
            }
        }
        .foregroundStyle(CarStyle.ink)
        .tint(CarStyle.accent(0))
        .padding(18)
        .background(CarStyle.pale(0).opacity(0.5), in: RoundedRectangle(cornerRadius: 24))
    }

    // MARK: Pausa

    private var pausedCard: some View {
        cardFrame {
            title("Pausa")
            options
            CarPrimaryButton(title: "SEGUIR", systemImage: "play.fill", color: .camGreen) {
                engine.resume()
            }
            exitLink()
        }
    }

    // MARK: Sin corazones

    private var outOfLivesCard: some View {
        cardFrame {
            title("¡Casi lo logran!")
            message("Vuelvan a intentarlo desde el último punto de control, con los corazones llenos.")
            CarPrimaryButton(title: "SEGUIR", systemImage: "arrow.clockwise", color: .camYellow) {
                engine.continueFromCheckpoint()
            }
            exitLink()
        }
    }

    // MARK: Meta

    private var wonCard: some View {
        cardFrame {
            title("¡LO LOGRARON!")
            HStack(spacing: 8) {
                Image(systemName: "star.fill")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundStyle(Color(hex: 0xF5A800))
                    .accessibilityHidden(true)
                Text("\(engine.starsCollected) de \(engine.level.stars.count)")
                    .camFont(34, .heavy)
                    .foregroundStyle(CarStyle.ink)
                    .monospacedDigit()
            }
            .accessibilityElement(children: .combine)
            message("Trabajaron en equipo y llegaron a la meta. ¡Juntaron \(engine.starsCollected) estrellas!")
            CarPrimaryButton(title: "¡CONTINUAR!", systemImage: "checkmark", color: .camGreen) {
                onFinish()
            }
        }
    }
}
