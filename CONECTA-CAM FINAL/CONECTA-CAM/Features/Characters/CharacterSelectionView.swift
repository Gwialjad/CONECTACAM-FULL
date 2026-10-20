//
//  CharacterSelectionView.swift
//  Conecta CAM
//

import SwiftUI

/// Pantalla "Elige a tu amigo": aparece después de presionar INICIAR.
struct CharacterSelectionView: View {
    @EnvironmentObject var store: AppStore
    let onContinue: () -> Void
    let onBack: () -> Void

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 22), count: 4)
    private var selected: Friend { Friend.with(id: store.profile.avatar) }

    var body: some View {
        ZStack {
            FriendsBackground()

            ScrollView {
                VStack(spacing: 26) {
                    VStack(spacing: 6) {
                        Text("Elige a tu amigo")
                            .camFont(64, .heavy)
                            .foregroundStyle(.white)
                            .shadow(color: Color.camBlue.opacity(0.45), radius: 0, y: 4)
                            .minimumScaleFactor(0.5)
                            .lineLimit(1)
                            .accessibilityAddTraits(.isHeader)
                        Text("¡Elige tu personaje favorito para comenzar!")
                            .camFont(26, .bold)
                            .foregroundStyle(.white.opacity(0.92))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 50)

                    LazyVGrid(columns: columns, spacing: 22) {
                        ForEach(Friend.all) { friend in
                            FriendCard(friend: friend, isSelected: friend.id == selected.id) {
                                Haptics.selection()
                                store.profile.avatar = friend.id
                            }
                        }
                    }
                    .frame(maxWidth: 1000)
                    .padding(.horizontal, 40)
                    .padding(.bottom, 20)
                }
                .frame(maxWidth: .infinity)
            }
            // Botón siempre visible abajo, aunque el texto sea muy grande.
            .safeAreaInset(edge: .bottom) {
                Button {
                    Haptics.impact(.medium)
                    onContinue()
                } label: {
                    Text("CONTINUAR")
                        .camFont(36, .heavy)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 70).padding(.vertical, 18)
                        .background(Capsule().fill(Color.camGreen))
                        .shadow(color: .black.opacity(0.2), radius: 6, y: 3)
                }
                .accessibilityLabel("Continuar con \(selected.name)")
                .accessibilityHint("Abre el menú principal")
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity)
            }
        }
        .overlay(alignment: .topLeading) {
            Button {
                Haptics.impact(.light)
                onBack()
            } label: {
                Label("Atrás", systemImage: "chevron.left")
                    .camFont(26, .heavy)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 22).padding(.vertical, 12)
                    .background(Capsule().fill(Color.white.opacity(0.25)))
            }
            .accessibilityHint("Regresa a la pantalla de inicio")
            .padding(.leading, 32)
            .padding(.top, 24)
        }
    }
}
