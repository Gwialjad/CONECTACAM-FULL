//
//  GameFlow.swift
//  Conecta CAM
//

import SwiftUI

/// Recorrido de cualquier actividad:
/// nombres de los jugadores -> cada jugador elige su personaje -> juego -> "¡Lo lograron juntos!".
/// Como todos los juegos pasan por aquí, los juegos nuevos heredan estos pasos automáticamente.
struct GameFlow: View {
    let game: Game
    let onExit: () -> Void
    @EnvironmentObject var store: AppStore
    @State private var players: [String]?
    @State private var others: [Friend] = []   // personajes del jugador 2, 3... (en orden)
    @State private var finished = false

    /// El primer jugador usa el personaje que eligió al inicio de la app.
    private var firstFriend: Friend { Friend.with(id: store.profile.avatar) }
    /// Personajes ya elegidos, en el mismo orden que `players`.
    private var chosen: [Friend] { [firstFriend] + others }

    var body: some View {
        ZStack {
            Color.camBlue.ignoresSafeArea()
            VStack {
                ScreenHeader(title: game.title.uppercased(), onClose: onExit)
                Group {
                    if finished {
                        FinishedView(onExit: onExit)
                    } else if let players {
                        if chosen.count < players.count {
                            // Falta que alguien elija su personaje
                            FriendPickerView(playerName: players[chosen.count],
                                             takenBy: takenBy(players)) { friend in
                                others.append(friend)
                            }
                            .id(chosen.count) // reinicia la selección para cada jugador
                        } else {
                            gameView(players)
                        }
                    } else {
                        PlayerSetupView { players = $0 }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .padding(.top, 20)
        }
    }

    @ViewBuilder
    private func gameView(_ players: [String]) -> some View {
        Group {
            switch game {
            case .story: StoryGame(players: players, onFinish: finish)
            case .questions: QuestionsGame(players: players, onFinish: finish)
            case .bonus: BonusGame(players: players, onFinish: finish)
            }
        }
        // Los juegos pueden leer los personajes con @Environment(\.gameFriends)
        .environment(\.gameFriends, chosen)
    }

    /// id de personaje -> nombre del jugador que ya lo eligió
    private func takenBy(_ players: [String]) -> [String: String] {
        var map: [String: String] = [:]
        for (i, friend) in chosen.enumerated() where i < players.count {
            map[friend.id] = players[i]
        }
        return map
    }

    private func finish() {
        guard let players, !finished else { return }
        store.logSession(game: game, players: players)
        finished = true
        Haptics.success()
    }
}
