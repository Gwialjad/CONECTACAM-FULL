//
//  ActivitiesView.swift
//  Conecta CAM
//

import SwiftUI

// MARK: - Actividades (hub de juegos colaborativos)

struct ActivitiesView: View {
    let onClose: () -> Void
    @State private var selected: Game?

    var body: some View {
        ZStack {
            Color.camBlue.ignoresSafeArea()
            VStack(alignment: .leading, spacing: 16) {
                ScreenHeader(title: "¿QUÉ VAN A HACER HOY?", onClose: onClose)
                Text("Todas las actividades se juegan entre 2 o más personas")
                    .camFont(26, .semibold)
                    .foregroundStyle(.white.opacity(0.9))
                    .padding(.leading, 32)

                RoundedRectangle(cornerRadius: 50).fill(Color(hex: 0xEAEFFB))
                    .overlay(
                        ScrollView {
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 300), spacing: 30)], spacing: 30) {
                                ForEach(Game.allCases) { game in
                                    Button {
                                        Haptics.impact(.light)
                                        selected = game
                                    } label: {
                                        VStack(spacing: 14) {
                                            Image(systemName: game.symbol)
                                                .font(.system(size: 80)) // icono gráfico en contenedor fijo
                                                .foregroundStyle(.white)
                                                .frame(width: 170, height: 170)
                                                .background(RoundedRectangle(cornerRadius: 36).fill(game.color))
                                                .shadow(radius: 6, y: 4)
                                            Text(game.title)
                                                .camFont(28, .bold)
                                                .foregroundStyle(Color.camBlue)
                                            Text(game.blurb)
                                                .camFont(20)
                                                .foregroundStyle(.secondary)
                                                .multilineTextAlignment(.center)
                                        }
                                        .padding(10)
                                    }
                                    // Un solo elemento por juego, sin leer el nombre del símbolo SF en inglés.
                                    .accessibilityElement(children: .ignore)
                                    .accessibilityLabel(game.title)
                                    .accessibilityHint("\(game.blurb) Mínimo \(Game.minPlayers) jugadores.")
                                    .accessibilityAddTraits(.isButton)
                                }
                            }
                            .padding(40)
                        }
                    )
                    .padding(.horizontal, 40)
                    .padding(.bottom, 40)
            }
            .padding(.top, 20)
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
    }
}
