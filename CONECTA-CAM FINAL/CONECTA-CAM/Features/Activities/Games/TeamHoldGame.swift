//
//  TeamHoldGame.swift
//  Conecta CAM
//

import SwiftUI
import Combine

// Juego 3: todos presionan a la vez (multitáctil)
struct TeamHoldGame: View {
    let players: [String]
    let onFinish: () -> Void
    @State private var pressed = Set<Int>()
    @State private var progress = 0.0
    @State private var done = false
    private let tick = 0.05
    private let duration = 5.0
    private let timer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                Text("Cada quien mantiene su círculo presionado. ¡Todos al mismo tiempo durante 5 segundos!")
                    .camFont(28, .bold)
                    .multilineTextAlignment(.center).foregroundStyle(.white)
                    .padding(.horizontal, 60)

                ProgressView(value: progress)
                    .progressViewStyle(.linear).tint(.camGreen).scaleEffect(y: 4)
                    .padding(.horizontal, 120)
                    .accessibilityLabel("Progreso del reto")
                    .accessibilityValue("\(Int(progress * 100)) por ciento")

                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: min(players.count, 3)), spacing: 24) {
                    ForEach(players.indices, id: \.self) { i in
                        Circle()
                            .fill(pressed.contains(i) ? Color.camGreen : .white)
                            .frame(width: 170, height: 170)
                            .overlay(Text(players[i]).camFont(26, .heavy)
                                .foregroundStyle(pressed.contains(i) ? .white : Color.camBlue)
                                .minimumScaleFactor(0.5).padding(8))
                            .gesture(DragGesture(minimumDistance: 0)
                                .onChanged { _ in
                                    if !pressed.contains(i) {
                                        Haptics.impact(.light)   // vibración al tocar
                                        pressed.insert(i)
                                    }
                                }
                                .onEnded { _ in pressed.remove(i) })
                            // VoiceOver: "toque directo" permite mantener presionado sin gestos de doble toque.
                            .accessibilityElement(children: .ignore)
                            .accessibilityLabel("Círculo de \(players[i])")
                            .accessibilityValue(pressed.contains(i) ? "presionado" : "suelto")
                            .accessibilityHint("Mantén el dedo sobre el círculo mientras los demás hacen lo mismo")
                            .accessibilityAddTraits(.allowsDirectInteraction)
                    }
                }
                .padding(.horizontal, 100)
            }
        }
        .onChange(of: pressed.count) { _, count in
            // Vibración más fuerte cuando todos ya están presionando.
            if count == players.count && !done { Haptics.impact(.medium) }
        }
        .onReceive(timer) { _ in
            guard !done else { return }
            if pressed.count == players.count {
                progress = min(1, progress + tick / duration)
                if progress >= 1 { done = true; onFinish() }
            } else {
                progress = max(0, progress - tick / duration * 2)
            }
        }
    }
}
