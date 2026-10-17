//
//  StoryGame.swift
//  Conecta CAM
//

import SwiftUI

// Juego 1: historia en cadena
struct StoryGame: View {
    let players: [String]
    let onFinish: () -> Void
    @State private var turn = 0
    @State private var sentence = ""
    @State private var story: [(author: String, text: String)] = []
    private var current: String { players[turn % players.count] }

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(story.indices, id: \.self) { i in
                            VStack(alignment: .leading, spacing: 2) {
                                Text(story[i].text).camFont(30)
                                Text("— \(story[i].author)").camFont(18).foregroundStyle(.secondary)
                            }
                            .accessibilityElement(children: .ignore)
                            .accessibilityLabel("\(story[i].author) dijo: \(story[i].text)")
                        }
                        if story.isEmpty {
                            Text("Aquí aparecerá su historia…")
                                .camFont(28).foregroundStyle(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(24)
                }
                .background(RoundedRectangle(cornerRadius: 24).fill(.white))
                .frame(height: 300)

                Text("Turno de \(current)")
                    .camFont(34, .heavy).foregroundStyle(.white)
                    .accessibilityAddTraits(.isHeader)
                TextField("Escribe la siguiente frase…", text: $sentence)
                    .camFont(28)
                    .padding(16)
                    .background(RoundedRectangle(cornerRadius: 16).fill(.white))
                    .accessibilityLabel("Frase de \(current)")
                    .accessibilityHint("Escribe una frase para continuar la historia")

                HStack(spacing: 20) {
                    Button {
                        Haptics.impact(.light)
                        story.append((current, sentence.trimmingCharacters(in: .whitespaces)))
                        sentence = ""
                        turn += 1
                    } label: { PillLabel(text: "AGREGAR", color: .camGreen) }
                    .disabled(sentence.trimmingCharacters(in: .whitespaces).isEmpty)
                    .accessibilityLabel("Agregar frase")
                    .accessibilityHint("Añade tu frase a la historia y pasa al siguiente turno")

                    // Termina cuando todos aportaron al menos una frase.
                    Button {
                        Haptics.impact(.medium)
                        onFinish()
                    } label: { PillLabel(text: "TERMINAR", color: .camYellow) }
                    .disabled(story.count < players.count)
                    .accessibilityLabel("Terminar historia")
                    .accessibilityHint(story.count < players.count
                                       ? "Se activa cuando todos hayan escrito al menos una frase"
                                       : "Finaliza la actividad")
                }
            }
            .padding(.horizontal, 60)
        }
        .onChange(of: turn) { _, _ in announce("Turno de \(current)") }
    }
}
