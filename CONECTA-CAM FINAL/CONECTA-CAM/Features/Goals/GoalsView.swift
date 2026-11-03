//
//  GoalsView.swift
//  Conecta CAM
//

import SwiftUI

// MARK: - Metas: completar los dos juegos y usar el diario desbloquea el juego especial

struct GoalsView: View {
    @EnvironmentObject var store: AppStore
    let onClose: () -> Void

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            ZStack {
                // Estrellas decorativas
                star(80, Color(hex: 0xFFC82E), x: w * 0.70, y: h * 0.08, angle: 10)
                star(64, Color(hex: 0x9AD6FF), x: w * 0.07, y: h * 0.11, angle: -12)
                star(56, Color(hex: 0xFFC82E), x: w * 0.035, y: h * 0.86, angle: 8)

                VStack(spacing: 12) {
                    closeRibbon
                    panel(w: w)
                    caption
                }
            }
            .frame(width: w, height: h)
        }
        .background(SkyBackground())
    }

    // MARK: Panel con las dos metas

    private func panel(w: CGFloat) -> some View {
        VStack(spacing: 18) {
            GoalRow(icon: "goal_games", title: "JUGAR DOS JUEGOS",
                    spoken: "Jugar dos juegos",
                    current: store.gamesCompleted, target: store.gamesGoal,
                    iconWidth: w * 0.23)
            GoalRow(icon: "goal_diary", title: "USAR DIARIO",
                    spoken: "Usar el diario",
                    current: store.diaryEntries, target: store.diaryGoal,
                    iconWidth: w * 0.23)
        }
        .padding(.horizontal, 40)
        .padding(.vertical, 24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(RoundedRectangle(cornerRadius: 80, style: .continuous)
            .fill(Color(hex: 0xDBEAFD)))
        .overlay(RoundedRectangle(cornerRadius: 80, style: .continuous)
            .stroke(Color.white.opacity(0.8), lineWidth: 6))
        .shadow(color: Color(hex: 0x1F5FB8).opacity(0.25), radius: 12, y: 6)
        .padding(.horizontal, 36)
    }

    private var caption: some View {
        Text(store.goalsComplete
             ? "¡Desbloqueaste el juego especial!"
             : "Completa las dos metas para desbloquear el juego especial")
            .camFont(26, .bold)
            .foregroundStyle(.white)
            .shadow(color: .black.opacity(0.2), radius: 3, y: 2)
            .multilineTextAlignment(.center)
            .minimumScaleFactor(0.6)
            .padding(.horizontal, 40)
            .padding(.bottom, 24)
    }

    // MARK: Cinta roja para volver

    private var closeRibbon: some View {
        HStack {
            Spacer()
            Button {
                Haptics.impact(.light)
                onClose()
            } label: {
                ZStack(alignment: .topTrailing) {
                    RibbonShape().fill(Color.camRed).frame(width: 220, height: 80)
                    Text("X")
                        .camFont(44, .heavy)
                        .foregroundStyle(.white)
                        .padding(.trailing, 28)
                }
            }
            .accessibilityLabel("Cerrar")
            .accessibilityHint("Regresa a la pantalla anterior")
        }
        .padding(.top, 8)
    }

    private func star(_ size: CGFloat, _ color: Color, x: CGFloat, y: CGFloat, angle: Double) -> some View {
        Image(systemName: "star.fill")
            .font(.system(size: size))
            .foregroundStyle(color)
            .shadow(color: .black.opacity(0.12), radius: 3, y: 3)
            .rotationEffect(.degrees(angle))
            .position(x: x, y: y)
            .accessibilityHidden(true) // decorativo
    }
}
