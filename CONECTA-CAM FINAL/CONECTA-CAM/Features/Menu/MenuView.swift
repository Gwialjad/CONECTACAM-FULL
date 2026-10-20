//
//  MenuView.swift
//  Conecta CAM
//

import SwiftUI

struct MenuView: View {
    let go: (Route) -> Void
    let onClose: () -> Void
    @EnvironmentObject var store: AppStore

    private var friend: Friend { Friend.with(id: store.profile.avatar) }

    var body: some View {
        ZStack {
            Color.camBlue.ignoresSafeArea()
            VStack(alignment: .leading, spacing: 24) {
                ScreenHeader(title: "¿QUÉ HAREMOS HOY?", onClose: onClose)
                ScrollView {
                    HStack(alignment: .center, spacing: 30) {
                        VStack(spacing: 24) {
                            menuButton("ACTIVIDADES", .camGreen, .activities,
                                       label: "Actividades",
                                       hint: "Juegos para jugar con otras personas")
                            menuButton("DIARIO", .camYellow, .diary,
                                       label: "Diario",
                                       hint: "Escribe lo que conociste hoy")
                            menuButton("METAS", .camCyan, .goals,
                                       label: "Metas",
                                       hint: "Mira tu progreso y tus rachas")
                        }
                        RoundedRectangle(cornerRadius: 50).fill(.white)
                            .frame(width: 420, height: 420)
                            .overlay(
                                Image(friend.imageName)
                                    .resizable()
                                    .scaledToFit()
                                    .padding(50)
                            )
                            .padding(.trailing, 30)
                            .accessibilityElement(children: .ignore)
                            .accessibilityLabel("Tu personaje: \(friend.name)")
                            .accessibilitySortPriority(-1)
                    }
                }
            }
            .padding(.top, 20)
        }
    }

    private func menuButton(_ title: String, _ color: Color, _ route: Route,
                            label: String, hint: String) -> some View {
        Button {
            Haptics.impact(.light)
            go(route)
        } label: {
            Text(title)
                .camFont(64, .heavy)
                .minimumScaleFactor(0.5)
                .lineLimit(1)
                .foregroundStyle(.white)
                .padding(.horizontal, 28)
                .frame(maxWidth: .infinity, minHeight: 200, alignment: .leading)
                .background(RoundedRectangle(cornerRadius: 26).fill(color))
                .overlay(RoundedRectangle(cornerRadius: 26).stroke(.white, lineWidth: 6))
        }
        .accessibilityLabel(label)
        .accessibilityHint(hint)
    }
}
