
//
//  CarGame.swift
//  Conecta CAM
//

import SwiftUI
import Combine

// Juego 3: carrera cooperativa
struct CarGame: View {

    let players: [String]
    let onFinish: () -> Void

    // MARK: - Estado del juego

    @State private var carPosition: CGFloat = 0
    @State private var verticalPosition: CGFloat = 0
    @State private var verticalSpeed: CGFloat = 0

    @State private var lives = 3
    @State private var accelerating = false
    @State private var invulnerability: CGFloat = 0

    @State private var gameOver = false
    @State private var won = false

    private let gravity: CGFloat = 1100
    private let jumpForce: CGFloat = 470
    private let speed: CGFloat = 230

    private let levelLength: CGFloat = 2800

    // Posiciones de los obstáculos
    private let spikes: [CGFloat] = [
        430, 1050, 1630, 2250
    ]

    private let pits: [ClosedRange<CGFloat>] = [
        700...850,
        1330...1490,
        1950...2120
    ]

    private let timer = Timer.publish(
        every: 1.0 / 30.0,
        on: .main,
        in: .common
    ).autoconnect()

    // MARK: - Jugadores

    private var playerOne: String {
        players.indices.contains(0) ? players[0] : "Jugador 1"
    }

    private var playerTwo: String {
        players.indices.contains(1) ? players[1] : "Jugador 2"
    }

    // MARK: - Pantalla principal

    var body: some View {
        GeometryReader { geometry in

            let groundY = geometry.size.height * 0.72
            let camera = max(
                0,
                carPosition - geometry.size.width * 0.22
            )

            ZStack {

                // Fondo del nivel
                LinearGradient(
                    colors: [
                        Color(hex: 0x54C8F5),
                        Color(hex: 0xA8E8FF)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                // Montañas
                HStack(alignment: .bottom, spacing: -50) {
                    ForEach(0..<5, id: \.self) { _ in
                        Image(systemName: "mountain.2.fill")
                            .font(.system(size: 150))
                            .foregroundStyle(Color(hex: 0x72BCEB))
                    }
                }
                .offset(y: -geometry.size.height * 0.30)

                // Nubes
                Image(systemName: "cloud.fill")
                    .font(.system(size: 90))
                    .foregroundStyle(.white)
                    .position(
                        x: geometry.size.width * 0.20,
                        y: 90
                    )

                Image(systemName: "cloud.fill")
                    .font(.system(size: 120))
                    .foregroundStyle(.white.opacity(0.9))
                    .position(
                        x: geometry.size.width * 0.80,
                        y: 150
                    )

                // Suelo
                Rectangle()
                    .fill(Color(hex: 0x75D957))
                    .frame(height: geometry.size.height - groundY)
                    .position(
                        x: geometry.size.width / 2,
                        y: groundY + (geometry.size.height - groundY) / 2
                    )

                // Decoración del suelo
                Rectangle()
                    .fill(Color(hex: 0xB87943))
                    .frame(height: 20)
                    .position(
                        x: geometry.size.width / 2,
                        y: groundY + 15
                    )

                // Agujeros
                ForEach(Array(pits.enumerated()), id: \.offset) { _, pit in

                    let x = pit.lowerBound - camera
                    let width = pit.upperBound - pit.lowerBound

                    if x + width > 0 && x < geometry.size.width {
                        Rectangle()
                            .fill(Color(hex: 0x173C67))
                            .frame(width: width, height: 100)
                            .position(
                                x: x + width / 2,
                                y: groundY + 40
                            )
                    }
                }

                // Pinchos
                ForEach(Array(spikes.enumerated()), id: \.offset) { _, spike in

                    let x = spike - camera

                    if x > -50 && x < geometry.size.width + 50 {
                        HStack(spacing: 2) {
                            ForEach(0..<3, id: \.self) { _ in
                                Image(systemName: "triangle.fill")
                                    .font(.system(size: 28))
                                    .foregroundStyle(Color.red)
                            }
                        }
                        .position(
                            x: x,
                            y: groundY - 15
                        )
                    }
                }

                // Línea de meta
                if levelLength - camera > 0 &&
                    levelLength - camera < geometry.size.width + 100 {

                    VStack(spacing: 0) {
                        Image(systemName: "flag.checkered")
                            .font(.system(size: 65))
                            .foregroundStyle(.white)

                        Rectangle()
                            .fill(.white)
                            .frame(width: 8, height: 100)
                    }
                    .position(
                        x: levelLength - camera,
                        y: groundY - 60
                    )
                }

                // Carro compartido
                Image("car_blue")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 145, height: 95)
                    .overlay {
                        if invulnerability > 0 {
                            Circle()
                                .stroke(.white, lineWidth: 4)
                                .frame(width: 145, height: 95)
                        }
                    }
                    .position(
                        x: max(
                            geometry.size.width * 0.22,
                            carPosition - camera
                        ),
                        y: groundY - 45 - verticalPosition
                    )

                // Interfaz superior
                VStack {

                    HStack {
                        Text("¡TRABAJO EN EQUIPO!")
                            .camFont(30, .heavy)
                            .foregroundStyle(.white)

                        Spacer()

                        Button {
                            gameOver = true
                            accelerating = false
                        } label: {
                            Text("✕")
                                .camFont(30, .heavy)
                                .foregroundStyle(.white)
                                .padding(12)
                                .background(Color.red, in: Circle())
                        }
                    }

                    HStack {
                        Label(
                            "\(lives)",
                            systemImage: "heart.fill"
                        )
                        .camFont(25, .heavy)
                        .foregroundStyle(.red)

                        Spacer()

                        Text("\(Int(min(carPosition / levelLength, 1) * 100))%")
                            .camFont(24, .heavy)
                            .foregroundStyle(.white)
                    }
                    .padding(.top, 8)

                    GeometryReader { bar in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(.white)

                            Capsule()
                                .fill(Color(hex: 0x75D957))
                                .frame(
                                    width: bar.size.width *
                                    min(carPosition / levelLength, 1)
                                )
                        }
                    }
                    .frame(height: 16)

                    Spacer()
                }
                .padding(25)

                // Controles de ambos jugadores
                VStack {
                    Spacer()

                    HStack(alignment: .bottom) {

                        // Jugador 1: acelerar
                        VStack(spacing: 8) {
                            Text(playerOne)
                                .camFont(20, .heavy)
                                .foregroundStyle(.white)

                            Text("ACELERAR")
                                .camFont(17, .heavy)
                                .foregroundStyle(.white)

                            Image(systemName: "arrow.right")
                                .font(.system(size: 45, weight: .heavy))
                                .foregroundStyle(.white)
                                .frame(width: 125, height: 105)
                                .background(
                                    RoundedRectangle(cornerRadius: 25)
                                        .fill(Color(hex: 0x2996F5))
                                )
                                .overlay {
                                    RoundedRectangle(cornerRadius: 25)
                                        .stroke(.white, lineWidth: 4)
                                }
                                .scaleEffect(accelerating ? 0.92 : 1)
                                .gesture(
                                    DragGesture(minimumDistance: 0)
                                        .onChanged { _ in
                                            if !gameOver && !won {
                                                accelerating = true
                                            }
                                        }
                                        .onEnded { _ in
                                            accelerating = false
                                        }
                                )
                                .accessibilityLabel("Acelerar")
                        }

                        Spacer()

                        // Jugador 2: saltar
                        VStack(spacing: 8) {
                            Text(playerTwo)
                                .camFont(20, .heavy)
                                .foregroundStyle(.white)

                            Text("SALTAR")
                                .camFont(17, .heavy)
                                .foregroundStyle(.white)

                            Image(systemName: "arrow.up")
                                .font(.system(size: 45, weight: .heavy))
                                .foregroundStyle(.white)
                                .frame(width: 125, height: 105)
                                .background(
                                    RoundedRectangle(cornerRadius: 25)
                                        .fill(Color(hex: 0xF5A623))
                                )
                                .overlay {
                                    RoundedRectangle(cornerRadius: 25)
                                        .stroke(.white, lineWidth: 4)
                                }
                                .onTapGesture {
                                    jump()
                                }
                                .accessibilityLabel("Saltar")
                        }
                    }
                    .padding(.horizontal, 35)
                    .padding(.bottom, 15)
                }

                // Pantalla de derrota
                if gameOver {
                    resultScreen(
                        title: "¡FIN DEL JUEGO!",
                        message: "¡No se rindan! Intenten otra vez.",
                        color: .red,
                        geometry: geometry
                    )
                }

                // Pantalla de victoria
                if won {
                    resultScreen(
                        title: "¡LO LOGRARON!",
                        message: "¡Trabajaron en equipo y llegaron a la meta!",
                        color: Color(hex: 0x75D957),
                        geometry: geometry
                    )
                }
            }
            .clipped()
            .onReceive(timer) { _ in
                updateGame()
            }
        }
    }

    // MARK: - Saltar

    private func jump() {
        guard !gameOver && !won && verticalPosition == 0 else {
            return
        }

        Haptics.impact(.light)
        verticalSpeed = jumpForce
    }

    // MARK: - Actualizar juego

    private func updateGame() {

        guard !gameOver && !won else {
            return
        }

        let delta: CGFloat = 1.0 / 30.0

        // Movimiento del carro
        if accelerating {
            carPosition += speed * delta
        }

        // Física del salto
        if verticalPosition > 0 || verticalSpeed > 0 {

            verticalSpeed -= gravity * delta
            verticalPosition += verticalSpeed * delta

            if verticalPosition <= 0 {
                verticalPosition = 0
                verticalSpeed = 0
            }
        }

        // Tiempo de protección después de recibir daño
        if invulnerability > 0 {
            invulnerability -= delta
        }

        // Caer en un agujero
        for pit in pits {
            if pit.contains(carPosition) && verticalPosition < 10 {
                gameOver = true
                accelerating = false
                return
            }
        }

        // Chocar con pinchos
        for spike in spikes {

            if abs(carPosition - spike) < 25 &&
                verticalPosition < 35 &&
                invulnerability <= 0 {

                lives -= 1
                invulnerability = 1.5

                Haptics.impact(.heavy)

                if lives <= 0 {
                    gameOver = true
                    accelerating = false
                    return
                }

                // Evita recibir daño varias veces
                // por el mismo obstáculo.
                carPosition += 55
            }
        }

        // Llegar a la meta
        if carPosition >= levelLength {
            won = true
            accelerating = false
            Haptics.impact(.heavy)
        }
    }

    // MARK: - Reiniciar

    private func restartGame() {
        carPosition = 0
        verticalPosition = 0
        verticalSpeed = 0
        lives = 3
        invulnerability = 0
        accelerating = false
        gameOver = false
        won = false
    }

    // MARK: - Resultado

    private func resultScreen(
        title: String,
        message: String,
        color: Color,
        geometry: GeometryProxy
    ) -> some View {

        ZStack {
            Color.black.opacity(0.65)
                .ignoresSafeArea()

            VStack(spacing: 20) {

                Text(title)
                    .camFont(42, .heavy)
                    .foregroundStyle(.white)

                Text(message)
                    .camFont(25, .bold)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)

                if won {
                    Button {
                        onFinish()
                    } label: {
                        PillLabel(text: "¡CONTINUAR!", color: .camGreen)
                    }
                } else {
                    Button {
                        restartGame()
                    } label: {
                        PillLabel(text: "INTENTAR OTRA VEZ", color: .camYellow)
                    }
                }
            }
            .padding(35)
            .frame(maxWidth: 600)
            .background(
                RoundedRectangle(cornerRadius: 35)
                    .fill(Color(hex: 0x438EDC))
            )
            .padding(30)
        }
    }
}
