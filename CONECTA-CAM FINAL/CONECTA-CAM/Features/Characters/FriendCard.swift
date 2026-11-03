
//
//  FriendCard.swift
//  Conecta CAM
//

import SwiftUI

/// Tarjeta de un personaje: imagen, nombre y marca de selección.
struct FriendCard: View {
    let friend: Friend
    let isSelected: Bool
    let isTaken: Bool
    let takenBy: String?
    let imageHeight: CGFloat
    let action: () -> Void

    private let selectedBlue = Color(hex: 0x2F80F5)

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(friend.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(height: imageHeight)
                    .padding(.top, 6)

                Text(friend.name)
                    .camFont(22, .heavy)
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)
                    .foregroundStyle(
                        isSelected ? Color.white : Color(hex: 0x3A6EA5)
                    )
                    .frame(maxWidth: .infinity, minHeight: 40)
                    .background(
                        Capsule().fill(
                            isSelected ? selectedBlue : Color(hex: 0xD3EAFB)
                        )
                    )
            }
            .padding(12)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 28)
                    .fill(Color(hex: isSelected ? 0xEEF9FF : 0xE7F6FE))
            )
            .overlay(alignment: .topTrailing) {
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 18, weight: .heavy))
                        .foregroundStyle(.white)
                        .frame(width: 36, height: 36)
                        .background(Circle().fill(selectedBlue))
                        .padding(10)
                }

                if isTaken {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 18, weight: .heavy))
                        .foregroundStyle(.white)
                        .frame(width: 36, height: 36)
                        .background(Circle().fill(Color.gray))
                        .padding(10)
                }
            }
            .opacity(isTaken ? 0.45 : 1.0)
            .shadow(
                color: isSelected ? Color.white.opacity(0.9) : .clear,
                radius: 14
            )
        }
        .buttonStyle(.plain)
        .disabled(isTaken)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(friend.name)
        .accessibilityHint(
            isTaken
            ? "Este personaje ya fue elegido por \(takenBy ?? "otro jugador")"
            : "Elige a \(friend.name) como tu personaje"
        )
        .accessibilityAddTraits(
            isSelected ? [.isButton, .isSelected] : [.isButton]
        )
    }
}
