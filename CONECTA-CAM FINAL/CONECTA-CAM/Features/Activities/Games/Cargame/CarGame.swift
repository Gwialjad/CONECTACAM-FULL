//
//  CarGame.swift
//  Conecta CAM
//
//  Juego 3: carrera cooperativa. Un jugador acelera y el otro salta;
//  juntos cruzan cuatro zonas, esquivan obstáculos y juntan estrellas.
//
//  Archivos de este juego (carpeta Car):
//    CarGame.swift            pantalla principal (este archivo)
//    CarGameEngine.swift      reglas: movimiento, choques, corazones, meta
//    CarLevel.swift           posiciones de obstáculos, estrellas y puntos de control
//    CarZone.swift            colores y "guion" de obstáculos de cada zona
//    CarWorldRenderer.swift   dibuja el mundo (Canvas)
//    CarHUD.swift             barra de arriba: zona, corazones, estrellas, progreso
//    CarControls.swift        botones de los dos jugadores
//    CarOverlays.swift        tarjetas de inicio, pausa, "casi" y meta
//    CarStyle.swift           colores, ayudas y botones compartidos
//

import SwiftUI

struct CarGame: View {
    let players: [String]
    /// Llegaron a la meta: GameFlow registra la partida y muestra "¡Lo lograron juntos!".
    let onFinish: () -> Void
    /// Se salió sin terminar: NO cuenta como una partida jugada.
    let onExit: () -> Void

    @Environment(\.gameFriends) private var friends
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.scenePhase) private var scenePhase

    @AppStorage(CarAssist.tapKey) private var tapToAccelerate = false
    @AppStorage(CarAssist.autoJumpKey) private var autoJump = false

    @State private var engine = CarGameEngine()
    @State private var confirmingExit = false

    private var assist: CarAssist {
        CarAssist(tapToAccelerate: tapToAccelerate, autoJump: autoJump)
    }
    private var overlayVisible: Bool { engine.phase != .playing }
    /// Cuando el juego no está en marcha se deja de redibujar (ahorra batería).
    private var worldPaused: Bool {
        engine.phase == .paused || engine.phase == .won || engine.phase == .outOfLives
    }

    var body: some View {
        ZStack {
            world

            VStack {
                CarHUD(engine: engine, onExit: requestExit, onPause: { engine.pause() })
                Spacer()
                CarControls(engine: engine, players: players, friends: friends,
                            tapToAccelerate: tapToAccelerate)
            }
            .padding(.horizontal, 28)
            .padding(.vertical, 14)
            .accessibilityHidden(overlayVisible)

            if overlayVisible {
                CarOverlay(
                    engine: engine,
                    players: players,
                    friends: friends,
                    tapToAccelerate: $tapToAccelerate,
                    autoJump: $autoJump,
                    onExit: requestExit,
                    onFinish: onFinish
                )
                .transition(.opacity)
            }
        }
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.25), value: overlayVisible)
        .confirmationDialog("¿Salir de la carrera?", isPresented: $confirmingExit, titleVisibility: .visible) {
            Button("Salir sin terminar", role: .destructive) { onExit() }
            Button("Seguir jugando", role: .cancel) {}
        } message: {
            Text("Se perderá el avance de la carrera.")
        }
        // Si la app pasa a segundo plano, el juego se pausa solo.
        .onChange(of: scenePhase) { _, phase in
            if phase != .active { engine.pause() }
        }
        .accessibilityAction(.escape) { requestExit() }
    }

    // MARK: Mundo

    private var world: some View {
        TimelineView(.animation(minimumInterval: nil, paused: worldPaused)) { timeline in
            Canvas { context, size in
                CarWorldRenderer.draw(
                    &context,
                    size: size,
                    engine: engine,
                    time: timeline.date.timeIntervalSinceReferenceDate,
                    reduceMotion: reduceMotion
                )
            }
            // Cada cuadro de pantalla avanza el juego.
            .onChange(of: timeline.date) { _, date in
                engine.tick(date, assist: assist)
            }
        }
        .ignoresSafeArea()
        // Para VoiceOver el mundo es un solo elemento con el resumen del avance.
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Carrera cooperativa")
        .accessibilityValue("Zona \(engine.zoneIndex + 1), \(engine.progressPercent) por ciento del camino")
        .accessibilityHidden(overlayVisible)
    }

    // MARK: Salir

    /// Si ya empezó la carrera, pregunta antes de salir para no perder el avance por un toque accidental.
    private func requestExit() {
        if engine.phase == .ready {
            onExit()
        } else {
            engine.pause()
            confirmingExit = true
        }
    }
}

#Preview(traits: .landscapeLeft) {
    CarGame(players: ["Ana", "Luis"], onFinish: {}, onExit: {})
        .environment(\.gameFriends, [Friend.with(id: "oveja"), Friend.with(id: "cerdito")])
}
