//
//  ActivitiesView.swift
//  Conecta CAM
//

import SwiftUI

// MARK: - Actividades (hub de juegos para 2 jugadores)

struct ActivitiesView: View {
    let onClose: () -> Void
    @EnvironmentObject var store: AppStore
    @State private var selected: Game?
    @State private var showLocked = false

    /// Pon `false` si no quieres ver el nombre de cada juego debajo del ícono.
    private let showNames = true

    private func isLocked(_ game: Game) -> Bool {
        game.needsUnlock && !store.goalsComplete
    }

    var body: some View {
        ZStack {
            SunnyBackground()
            VStack(spacing: 0) {
                header
                gamesPanel
            }
            // Mientras hay un juego abierto, VoiceOver no debe entrar a la pantalla de fondo.
            .accessibilityHidden(selected != nil)

            if let game = selected {
                GameFlow(game: game, onExit: { selected = nil })
                    .transition(.move(edge: .bottom))
                    .zIndex(1)
                    .accessibilityAddTraits(.isModal)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: selected)
        .alert("Juego bloqueado", isPresented: $showLocked) {
            Button("Entendido", role: .cancel) {}
        } message: {
            Text("Cumple todas tus metas para desbloquear este juego.")
        }
    }

    // MARK: Encabezado

    private var header: some View {
        HStack(alignment: .top) {
            HStack(spacing: 14) {
                Sparkles()
                OutlinedTitle(text: "2 JUGADORES")
                Sparkles(mirrored: true)
            }
            .padding(.leading, 40)
            .padding(.top, 8)
            Spacer()
            Button {
                Haptics.impact(.light)
                onClose()
            } label: {
                ZStack(alignment: .topTrailing) {
                    RibbonShape().fill(Color.camRed).frame(width: 220, height: 80)
                    Text("X")
                        .camFont(44, .heavy)
                        .foregroundStyle(.white)
                        .padding(.trailing, 28)
                }
            }
            .accessibilityLabel("Cerrar")
            .accessibilityHint("Regresa a la pantalla anterior")
        }
        .padding(.top, 24)
        .padding(.bottom, 16)
    }

    // MARK: Panel con los 3 juegos

    private var gamesPanel: some View {
        HStack(alignment: .center, spacing: 16) {
            ForEach(Game.allCases) { game in
                tile(game)
            }
        }
        .padding(.horizontal, 36)
        .padding(.vertical, 24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(RoundedRectangle(cornerRadius: 70, style: .continuous)
            .fill(Color(hex: 0xFDF4E6)))
        .overlay(RoundedRectangle(cornerRadius: 70, style: .continuous)
            .stroke(Color.white, lineWidth: 8))
        .shadow(color: Color(hex: 0xC77A00).opacity(0.18), radius: 12, y: 6)
        .padding(.horizontal, 36)
        .padding(.bottom, 44)
    }

    private func tile(_ game: Game) -> some View {
        let locked = isLocked(game)
        return Button {
            if locked {
                Haptics.warning()
                showLocked = true
            } else {
                Haptics.impact(.light)
                selected = game
            }
        } label: {
            VStack(spacing: 8) {
                tileArt(game, locked: locked)
                if showNames {
                    Text(game.title)
                        .camFont(24, .heavy)
                        .foregroundStyle(locked ? Color(hex: 0x8A8798) : Color(hex: 0xB7691A))
                        .minimumScaleFactor(0.6)
                        .lineLimit(1)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(TileButtonStyle())
        // Un solo elemento por juego para VoiceOver.
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(locked ? "\(game.title), bloqueado" : game.title)
        .accessibilityHint(locked
                           ? "Cumple todas tus metas para desbloquearlo."
                           : "\(game.blurb) Para \(Game.playerCount) jugadores.")
        .accessibilityAddTraits(.isButton)
    }

    /// Arte del botón. El juego especial, ya desbloqueado, usa un ícono provisional
    /// hasta que exista el arte final (sin candado).
    @ViewBuilder
    private func tileArt(_ game: Game, locked: Bool) -> some View {
        if game.needsUnlock && !locked {
            ZStack {
                RoundedRectangle(cornerRadius: 90, style: .continuous)
                    .fill(LinearGradient(colors: [Color(hex: 0x6FD3FF), Color(hex: 0x2F80F5)],
                                         startPoint: .top, endPoint: .bottom))
                Image(systemName: "car.fill")
                    .font(.system(size: 110))
                    .foregroundStyle(.white)
            }
            .aspectRatio(1, contentMode: .fit)
            .shadow(color: Color(hex: 0x2F80F5).opacity(0.35), radius: 10, y: 8)
            .padding(24)
        } else {
            Image(game.iconName)
                .resizable()
                .scaledToFit()
        }
    }
}

/// Al presionar, el ícono se encoge un poquito.
private struct TileButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.94 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

/// Rayitas blancas decorativas al lado del título.
private struct Sparkles: View {
    var mirrored = false
    var body: some View {
        VStack(spacing: 8) {
            Capsule().fill(Color.white).frame(width: 42, height: 10)
                .rotationEffect(.degrees(mirrored ? -25 : 25))
            Capsule().fill(Color.white).frame(width: 42, height: 10)
                .rotationEffect(.degrees(mirrored ? 10 : -10))
        }
        .accessibilityHidden(true)
    }
}
