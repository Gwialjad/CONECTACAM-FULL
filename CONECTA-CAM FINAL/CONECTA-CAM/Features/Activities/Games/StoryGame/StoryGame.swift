//
//  StoryGame.swift
//  Conecta CAM
//
//  Historia en cadena: cada jugador arma una frase con las palabras de su turno.
//  Al agregarla, el turno pasa al otro jugador, la pantalla cambia de color
//  y llegan palabras nuevas.
//
//  Jugador 1 = azul, jugador 2 = rojo; cada quien ve a su propio personaje.
//
//  Archivos de este juego (carpeta Story):
//    StoryGame.swift          estado y reglas del juego (este archivo)
//    StoryPanel.swift         tarjeta blanca: título, historia y frase en curso
//    StoryWordBankView.swift  las 10 palabras del turno
//    StoryCharacterCard.swift personaje del jugador en turno
//    StoryControls.swift      botones TERMINAR y salir, estilo de botón
//    StoryWordBank.swift      todas las palabras, por tipo
//    StoryWordDeck.swift      reparte palabras nuevas y arma las frases
//    StoryScene.swift         colores y paisaje de cada jugador
//

import SwiftUI

struct StoryGame: View {
    let players: [String]
    /// La historia terminó: GameFlow registra la sesión y muestra "¡Lo lograron juntos!".
    let onFinish: () -> Void
    /// Se salió sin terminar: NO cuenta como una partida jugada.
    let onExit: () -> Void

    @Environment(\.gameFriends) private var friends

    @State private var turn = 0
    @State private var deck: StoryWordDeck
    @State private var hand: [StoryWord]
    @State private var selectedWords: [String] = []
    @State private var story: [StoryContribution] = []
    @State private var confirmingExit = false

    /// Título de la tarjeta de la historia.
    private let storyPrompt = "Cuando era..."

    init(players: [String], onFinish: @escaping () -> Void, onExit: @escaping () -> Void) {
        self.players = players
        self.onFinish = onFinish
        self.onExit = onExit

        // La primera mano de palabras se reparte al empezar.
        var deck = StoryWordDeck()
        let firstHand = deck.nextHand()
        _deck = State(initialValue: deck)
        _hand = State(initialValue: firstHand)
    }

    // MARK: Estado derivado

    private var playerCount: Int { max(players.count, 1) }
    private var currentIndex: Int { turn % playerCount }
    private var theme: StoryTheme { .forPlayer(currentIndex) }

    private var currentName: String {
        players.indices.contains(currentIndex) ? players[currentIndex] : "Jugador \(currentIndex + 1)"
    }
    /// Personaje que el jugador eligió en la pantalla "Elige a tu amigo".
    private var currentFriend: Friend? {
        friends.indices.contains(currentIndex) ? friends[currentIndex] : nil
    }

    /// La frase en curso, ya con mayúscula inicial.
    private var sentence: String { StorySentence.compose(selectedWords) }

    /// Se puede terminar cuando cada jugador ya agregó al menos una frase
    /// (los turnos son alternados, así que basta con contar las frases).
    private var canFinish: Bool { !players.isEmpty && story.count >= players.count }

    // MARK: Pantalla

    var body: some View {
        GeometryReader { geo in
            let cardWidth = min(max(geo.size.width * 0.20, 190), 270)

            ZStack {
                StorySceneBackground(playerIndex: currentIndex)

                HStack(alignment: .top, spacing: 18) {
                    VStack(spacing: 18) {
                        StoryPanel(
                            prompt: storyPrompt,
                            story: story,
                            sentence: sentence,
                            theme: theme,
                            onDelete: removeLastWord,
                            onAdd: { commitSentence() }
                        )
                        StoryWordBankView(words: hand, theme: theme, onPick: addWord)
                    }
                    .frame(maxHeight: .infinity)

                    VStack(spacing: 14) {
                        StoryExitButton(
                            theme: theme,
                            confirming: $confirmingExit,
                            onRequest: requestExit,
                            onLeave: onExit
                        )
                        .frame(maxWidth: .infinity, alignment: .trailing)

                        StoryCharacterCard(
                            name: currentName,
                            friend: currentFriend,
                            playerIndex: currentIndex,
                            theme: theme
                        )

                        StoryFinishButton(isEnabled: canFinish, action: finishGame)
                    }
                    .frame(width: cardWidth)
                    .frame(maxHeight: .infinity)
                }
                .padding(.horizontal, 28)
                .padding(.top, 14)
                .padding(.bottom, max(18, geo.size.height * 0.07))
                .frame(maxWidth: 1250, maxHeight: .infinity)
            }
        }
        .accessibilityAction(.escape) { requestExit() }
        .onAppear { announce("Historia en cadena. Turno de \(currentName)") }
    }

    // MARK: Acciones

    private func addWord(_ word: StoryWord) {
        Haptics.impact(.light)
        selectedWords.append(word.text)
        announce("\(word.text) agregada a tu frase")
    }

    private func removeLastWord() {
        guard let removed = selectedWords.popLast() else { return }
        Haptics.impact(.light)
        announce("\(removed) borrada")
    }

    /// Guarda la frase, pasa el turno y reparte palabras nuevas.
    /// Devuelve `false` si no había nada que guardar.
    @discardableResult
    private func commitSentence(announceTurn: Bool = true) -> Bool {
        let text = StorySentence.compose(selectedWords, addingPeriod: true)
        guard !text.isEmpty else { return false }

        Haptics.impact(.medium)
        story.append(StoryContribution(playerIndex: currentIndex, author: currentName, text: text))
        selectedWords.removeAll()
        turn += 1
        hand = deck.nextHand()

        if announceTurn {
            announce("Frase agregada. Turno de \(currentName). Hay palabras nuevas.")
        }
        return true
    }

    private func finishGame() {
        // Si quedó una frase a medias, se agrega para que no se pierda.
        commitSentence(announceTurn: false)
        Haptics.impact(.medium)
        onFinish()
    }

    /// Pregunta antes de salir si ya hay algo escrito, para no perder la historia por un toque accidental.
    private func requestExit() {
        if story.isEmpty && selectedWords.isEmpty {
            onExit()
        } else {
            confirmingExit = true
        }
    }
}

#Preview(traits: .landscapeLeft) {
    StoryGame(players: ["Ana", "Luis"], onFinish: {}, onExit: {})
        .environment(\.gameFriends, [Friend.with(id: "oveja"), Friend.with(id: "cerdito")])
}
