//
//  PlayerSetupView.swift
//  Conecta CAM
//

import SwiftUI

/// Pide los nombres de los 2 jugadores (distintos y no vacíos) antes de empezar.
struct PlayerSetupView: View {
    @EnvironmentObject var store: AppStore
    let onStart: ([String]) -> Void
    @State private var names: [String] = ["", ""]

    private var cleaned: [String] {
        var seen = Set<String>()
        return names.map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty && seen.insert($0.lowercased()).inserted }
    }
    private var ready: Bool { cleaned.count == Game.playerCount }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("¿Quiénes van a jugar?")
                    .camFont(40, .heavy).foregroundStyle(.white)
                    .accessibilityAddTraits(.isHeader)
                Text("Este juego es para \(Game.playerCount) personas")
                    .camFont(24).foregroundStyle(.white.opacity(0.9))

                VStack(spacing: 12) {
                    ForEach(names.indices, id: \.self) { i in
                        TextField("Nombre del jugador \(i + 1)", text: $names[i])
                            .camFont(28)
                            .padding(16)
                            .background(RoundedRectangle(cornerRadius: 16).fill(.white))
                            .accessibilityLabel("Nombre del jugador \(i + 1)")
                            .accessibilityHint("Escribe el nombre de quien va a jugar")
                    }
                }
                .frame(maxWidth: 600)

                Button {
                    Haptics.impact(.medium)
                    onStart(cleaned)
                } label: {
                    Text("¡EMPEZAR!")
                        .camFont(36, .heavy)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 60).padding(.vertical, 20)
                        .background(Capsule().fill(ready ? Color.camGreen : .gray))
                }
                .disabled(!ready)
                .accessibilityLabel("Empezar actividad")
                .accessibilityHint(ready
                                   ? "Comienza el juego"
                                   : "Escribe los nombres de los 2 jugadores, distintos entre sí, para activar este botón")
            }
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
        }
        .onAppear { if names[0].isEmpty { names[0] = store.profile.name } }
    }
}
