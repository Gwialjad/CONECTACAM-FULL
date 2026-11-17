//
//  StoryCharacterCard.swift
//  Conecta CAM
//
//  La tarjeta del personaje del jugador en turno.
//

import SwiftUI

struct StoryCharacterCard: View {
    let name: String
    /// Personaje que el jugador eligió en "Elige a tu amigo" (nil = ícono de respaldo).
    let friend: Friend?
    let playerIndex: Int
    let theme: StoryTheme

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                CardStars(color: .white.opacity(0.55))
                character
                    .id(playerIndex) // el personaje cambia con un fundido en cada turno
                    .transition(.opacity)
            }
            .frame(maxHeight: .infinity)

            Text(name)
                .camFont(24, .heavy)
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(theme.accent, in: Capsule())
        }
        .padding(12)
        .background(theme.pale, in: RoundedRectangle(cornerRadius: 30))
        .overlay(RoundedRectangle(cornerRadius: 30).stroke(.white.opacity(0.85), lineWidth: 5))
        .overlay(alignment: .topTrailing) {
            Sparkle().rotationEffect(.degrees(180)).offset(x: 16, y: 40)
        }
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.4), value: playerIndex)
        // VoiceOver lo lee como un solo encabezado: "Turno de Ana".
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Turno de \(name)")
        .accessibilityAddTraits(.isHeader)
    }

    @ViewBuilder
    private var character: some View {
        if let friend {
            Image(friend.imageName)
                .resizable()
                .scaledToFit()
                .padding(.horizontal, 6)
        } else {
            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .scaledToFit()
                .foregroundStyle(theme.accent.opacity(0.6))
                .padding(30)
        }
    }
}
