//
//  GameFlow.swift
//  Conecta CAM
//

import SwiftUI

struct GameFlow: View {
    let game: Game
    let onExit: () -> Void
    @EnvironmentObject var store: AppStore
    @State private var players: [String]?
    @State private var finished = false

    var body: some View {
        ZStack {
            Color.camBlue.ignoresSafeArea()
            VStack {
                ScreenHeader(title: game.title.uppercased(), onClose: onExit)
                Group {
                    if finished {
                        FinishedView(onExit: onExit)
                    } else if let players {
                        switch game {
                        case .story: StoryGame(players: players, onFinish: finish)
                        case .questions: QuestionsGame(players: players, onFinish: finish)
                        case .teamHold: TeamHoldGame(players: players, onFinish: finish)
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

    private func finish() {
        guard let players, !finished else { return }
        store.logSession(game: game, players: players)
        finished = true
        Haptics.success()
    }
}
