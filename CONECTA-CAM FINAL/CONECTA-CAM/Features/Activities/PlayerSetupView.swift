//
//  PlayerSetupView.swift
//  Conecta CAM
//

import SwiftUI

/// Exige al menos 2 jugadores distintos antes de empezar.
struct PlayerSetupView: View {
    @EnvironmentObject var store: AppStore
    let onStart: ([String]) -> Void
    @State private var names: [String] = []

    private var cleaned: [String] {
        var seen = Set<String>()
        return names.map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty && seen.insert($0.lowercased()).inserted }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("¿Quiénes van a jugar?")
                    .camFont(40, .heavy).foregroundStyle(.white)
                    .accessibilityAddTraits(.isHeader)
                Text("Se necesitan mínimo \(Game.minPlayers) personas")
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
                    if names.count < Game.maxPlayers {
                        Button {
                            Haptics.selection()
                            names.append("")
                        } label: {
                            Label("Agregar jugador", systemImage: "plus.circle.fill")
                                .camFont(26, .bold)
                                .foregroundStyle(.white)
                                .frame(minHeight: 44)
                        }
                        .accessibilityHint("Añade un campo para otro jugador. Máximo \(Game.maxPlayers).")
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
                        .background(Capsule().fill(cleaned.count >= Game.minPlayers ? Color.camGreen : .gray))
                }
                .disabled(cleaned.count < Game.minPlayers)
                .accessibilityLabel("Empezar actividad")
                .accessibilityHint(cleaned.count >= Game.minPlayers
                                   ? "Comienza el juego"
                                   : "Escribe al menos \(Game.minPlayers) nombres distintos para activar este botón")
            }
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
        }
        .onAppear { if names.isEmpty { names = [store.profile.name, ""] } }
    }
}
