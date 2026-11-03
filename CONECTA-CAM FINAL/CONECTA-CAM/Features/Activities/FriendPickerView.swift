//
//  FriendPickerView.swift
//  Conecta CAM
//

import SwiftUI

/// Pantalla para que un jugador elija su personaje dentro de una actividad.
/// Los personajes ya elegidos por otros jugadores aparecen en gris y no se pueden tocar.
struct FriendPickerView: View {
    let playerName: String
    /// id del personaje -> nombre del jugador que ya lo eligió
    let takenBy: [String: String]
    let onPick: (Friend) -> Void

    @State private var selectedID: String?
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 18), count: 4)

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                Text("Turno de \(playerName)")
                    .camFont(40, .heavy)
                    .foregroundStyle(.white)
                    .accessibilityAddTraits(.isHeader)
                Text("Elige a tu amigo")
                    .camFont(28, .bold)
                    .foregroundStyle(.white.opacity(0.92))

                LazyVGrid(columns: columns, spacing: 18) {
                    ForEach(Friend.all) { friend in
                        FriendCard(friend: friend,
                                   isSelected: selectedID == friend.id,
                                   isTaken: takenBy[friend.id] != nil,
                                   takenBy: takenBy[friend.id],
                                   imageHeight: 90) {
                            Haptics.selection()
                            selectedID = friend.id
                        }
                    }
                }
                .frame(maxWidth: 900)
                .padding(.horizontal, 40)
            }
            .frame(maxWidth: .infinity)
            .padding(.bottom, 12)
        }
        // Botón siempre visible abajo, aunque el texto sea muy grande.
        .safeAreaInset(edge: .bottom) {
            Button {
                guard let id = selectedID else { return }
                Haptics.impact(.medium)
                onPick(Friend.with(id: id))
            } label: {
                Text("¡LISTO!")
                    .camFont(36, .heavy)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 70).padding(.vertical, 18)
                    .background(Capsule().fill(selectedID == nil ? Color.gray : Color.camGreen))
            }
            .disabled(selectedID == nil)
            .accessibilityLabel("Listo")
            .accessibilityHint(selectedID == nil
                               ? "Elige un personaje para activar este botón"
                               : "Continúa con la actividad")
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
        }
        .onAppear { announce("Turno de \(playerName). Elige a tu amigo.") }
    }
}
