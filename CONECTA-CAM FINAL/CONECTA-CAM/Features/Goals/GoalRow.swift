//
//  GoalRow.swift
//  Conecta CAM
//

import SwiftUI

/// Una meta: ícono, título con contorno azul y barra de progreso verde.
struct GoalRow: View {
    let icon: String          // nombre en Assets.xcassets
    let title: String
    let spoken: String        // lo que lee VoiceOver
    let current: Int
    let target: Int
    let iconWidth: CGFloat

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var shown: Double = 0   // progreso que se ve (se anima)

    private var progress: Double { target > 0 ? min(Double(current) / Double(target), 1) : 0 }
    private var done: Bool { target > 0 && current >= target }

    var body: some View {
        HStack(spacing: 28) {
            Image(icon)
                .resizable()
                .scaledToFit()
                .frame(width: iconWidth)
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 12) {
                    OutlinedTitle(text: title, size: 40,
                                  outline: Color(hex: 0x2F80F5), depth: Color(hex: 0x1D5FCF))
                    if done {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 36))
                            .foregroundStyle(Color.camGreen)
                    }
                }
                bar
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .onAppear { setShown(progress) }
        .onChange(of: progress) { _, new in setShown(new) }
        // Un solo elemento para VoiceOver: nombre + progreso.
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(spoken)
        .accessibilityValue(done ? "\(current) de \(target). Meta cumplida" : "\(current) de \(target)")
    }

    private var bar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(Color.white)
                    .overlay(Capsule().stroke(Color(hex: 0xD2DBF0), lineWidth: 4))
                    .shadow(color: Color(hex: 0x9FB4E0).opacity(0.55), radius: 5, y: 3)
                if shown > 0 {
                    Capsule()
                        .fill(LinearGradient(colors: [Color(hex: 0x9BEE56), Color(hex: 0x4DB92C)],
                                             startPoint: .top, endPoint: .bottom))
                        .overlay(alignment: .top) {
                            // brillo de la barra
                            Capsule().fill(Color.white.opacity(0.35))
                                .frame(height: 10)
                                .padding(.horizontal, 16)
                                .padding(.top, 5)
                        }
                        .frame(width: max(geo.size.height - 12, (geo.size.width - 12) * shown),
                               height: geo.size.height - 12)
                        .padding(6)
                }
            }
        }
        .frame(height: 64)
    }

    /// La barra se llena despacito, salvo que el iPad tenga "Reducir movimiento".
    private func setShown(_ value: Double) {
        if reduceMotion {
            shown = value
        } else {
            withAnimation(.easeOut(duration: 0.9)) { shown = value }
        }
    }
}
