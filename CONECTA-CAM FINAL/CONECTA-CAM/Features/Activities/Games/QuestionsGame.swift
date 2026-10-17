//
//  QuestionsGame.swift
//  Conecta CAM
//

import SwiftUI

// Juego 2: preguntas para conocerse
struct QuestionsGame: View {
    let players: [String]
    let onFinish: () -> Void
    @State private var turn = 0
    @State private var questions = [
        "¿Cuál es tu comida favorita y por qué?",
        "¿Qué te hace reír mucho?",
        "¿Qué te gustaría aprender a hacer?",
        "¿Cuál es tu lugar favorito?",
        "Cuéntanos de algo que te hizo sentir orgulloso.",
        "¿Qué te gusta hacer con tus amigos?",
        "Si tuvieras un superpoder, ¿cuál sería?",
        "¿Qué animal te gustaría tener de mascota?",
        "¿Qué puedo hacer para que te sientas bien cuando estás triste?",
        "¿Qué cualidad admiras en las demás personas?"
    ].shuffled()

    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                Text("Turno de \(players[turn % players.count])")
                    .camFont(40, .heavy).foregroundStyle(.white)
                    .accessibilityAddTraits(.isHeader)
                Text(questions[turn % questions.count])
                    .camFont(40, .bold)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color.camBlue)
                    .padding(40)
                    .frame(maxWidth: 800, minHeight: 240)
                    .background(RoundedRectangle(cornerRadius: 30).fill(.white))
                    .accessibilityLabel("Pregunta: \(questions[turn % questions.count])")
                Text("Las demás personas escuchan con atención 👂")
                    .camFont(24).foregroundStyle(.white.opacity(0.9))
                    .accessibilityLabel("Las demás personas escuchan con atención")
                HStack(spacing: 20) {
                    Button {
                        Haptics.impact(.light)
                        turn += 1
                    } label: { PillLabel(text: "SIGUIENTE", color: .camGreen) }
                    .accessibilityLabel("Siguiente pregunta")
                    .accessibilityHint("Pasa al turno de la siguiente persona")

                    Button {
                        Haptics.impact(.medium)
                        onFinish()
                    } label: { PillLabel(text: "TERMINAR", color: .camYellow) }
                    .disabled(turn + 1 < players.count) // todos responden al menos una vez
                    .accessibilityLabel("Terminar actividad")
                    .accessibilityHint(turn + 1 < players.count
                                       ? "Se activa cuando todos hayan respondido al menos una vez"
                                       : "Finaliza la actividad")
                }
            }
            .frame(maxWidth: .infinity)
        }
        .onChange(of: turn) { _, _ in
            announce("Turno de \(players[turn % players.count]). \(questions[turn % questions.count])")
        }
    }
}
