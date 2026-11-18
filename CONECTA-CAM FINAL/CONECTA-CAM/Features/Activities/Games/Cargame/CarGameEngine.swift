//
//  CarGameEngine.swift
//  Conecta CAM
//
//  Las reglas de la carrera: movimiento, salto, choques, agujeros,
//  estrellas, puntos de control y meta.
//
//  Los números de la física (velocidad, salto, tamaño del carro y de los
//  obstáculos) se probaron con una simulación para comprobar que TODOS los
//  obstáculos se pueden pasar con un margen de más de un tercio de segundo.
//  Si los cambias, vuelve a probar el nivel completo.
//

import SwiftUI
import Observation

enum CarPhase: Equatable {
    case ready        // tarjeta de inicio
    case playing
    case paused
    case outOfLives   // se acabaron los corazones: seguir desde el último punto de control
    case won
}

/// Una nubecita de polvo que sale de las llantas.
struct CarDust {
    var x: CGFloat
    var y: CGFloat
    var age: Double
    let life: Double
    let size: CGFloat
}

@Observable
final class CarGameEngine {

    // MARK: Física

    static let gravity: CGFloat = 1800
    static let jumpSpeed: CGFloat = 800          // salto de unos 180 puntos de alto
    static let airTime: CGFloat = 2 * jumpSpeed / gravity
    static let cruiseSpeed: CGFloat = 300
    static let acceleration: CGFloat = 800
    static let braking: CGFloat = 600
    static let mudFactor: CGFloat = 0.5          // en un charco el carro va a la mitad
    static let carHalfWidth: CGFloat = 30        // la caja de choque es más chica que el dibujo
    static let carHeight: CGFloat = 52
    static let startX: CGFloat = 150
    static let maxLives = 3
    static let invulnerableSeconds: Double = 1.6

    let level: CarLevel

    // MARK: Lo que muestra la pantalla (observado)

    var phase: CarPhase = .ready
    var lives = CarGameEngine.maxLives
    var starsCollected = 0
    var zoneIndex = 0
    var isAccelerating = false
    /// 0...1, se actualiza en cada cuadro (solo lo lee la barra de progreso).
    var progress: CGFloat = 0
    /// Porcentaje entero, cambia pocas veces (para VoiceOver).
    var progressPercent = 0

    // MARK: Simulación (el dibujo la lee en cada cuadro; no se observa)

    @ObservationIgnored private(set) var carX: CGFloat = CarGameEngine.startX
    @ObservationIgnored private(set) var carY: CGFloat = 0           // altura sobre el suelo
    @ObservationIgnored private(set) var verticalSpeed: CGFloat = 0
    @ObservationIgnored private(set) var speed: CGFloat = 0
    @ObservationIgnored private(set) var invulnerable: Double = 0
    @ObservationIgnored private(set) var collectedStars: Set<Int> = []
    @ObservationIgnored private(set) var dust: [CarDust] = []

    @ObservationIgnored private var checkpointX: CGFloat = CarGameEngine.startX
    @ObservationIgnored private var respawnX: CGFloat = CarGameEngine.startX
    @ObservationIgnored private var fallSeconds: Double = 0
    @ObservationIgnored private var jumpBuffer: Double = 0
    @ObservationIgnored private var dustTimer: Double = 0
    @ObservationIgnored private var autoJumpedHazardID = -1
    @ObservationIgnored private var lastTick: Date?

    init(level: CarLevel = .standard) {
        self.level = level
    }

    /// Dónde está la "cámara": el carro se queda a un cuarto de la pantalla.
    func cameraX(forWidth width: CGFloat) -> CGFloat {
        max(0, carX - width * 0.25)
    }

    // MARK: Control del juego

    /// Desde la tarjeta "¡Carrera en equipo!".
    func begin() {
        guard phase == .ready else { return }
        phase = .playing
        lastTick = nil
        announce("¡Ya! Zona 1: \(level.zones[0].name)")
    }

    func pause() {
        guard phase == .playing else { return }
        phase = .paused
        isAccelerating = false
        announce("Pausa")
    }

    func resume() {
        guard phase == .paused else { return }
        phase = .playing
        lastTick = nil
    }

    /// Después de quedarse sin corazones: vuelven al último punto de control con los corazones llenos.
    func continueFromCheckpoint() {
        guard phase == .outOfLives else { return }
        carX = checkpointX
        carY = 0
        verticalSpeed = 0
        speed = 0
        lives = CarGameEngine.maxLives
        invulnerable = 1.5
        fallSeconds = 0
        jumpBuffer = 0
        autoJumpedHazardID = -1
        isAccelerating = false
        phase = .playing
        lastTick = nil
    }

    func setAccelerating(_ on: Bool) {
        guard phase == .playing, isAccelerating != on else { return }
        isAccelerating = on
    }

    func toggleAccelerating() {
        setAccelerating(!isAccelerating)
    }

    func jump() {
        guard phase == .playing, fallSeconds <= 0 else { return }
        if carY <= 0.5 && verticalSpeed <= 0 {
            startJump()
        } else {
            // Si tocan un poquito antes de aterrizar, el salto se guarda un instante.
            jumpBuffer = 0.14
        }
    }

    // MARK: Avance del tiempo

    /// Se llama en cada cuadro de la pantalla.
    func tick(_ now: Date, assist: CarAssist) {
        let previous = lastTick
        lastTick = now
        guard phase == .playing, let previous else { return }
        // Si un cuadro tarda mucho, no se avanza de golpe (evita atravesar obstáculos).
        let seconds = min(max(now.timeIntervalSince(previous), 0), 1.0 / 30.0)
        step(CGFloat(seconds), seconds: seconds, assist: assist)
    }

    private func step(_ dt: CGFloat, seconds: Double, assist: CarAssist) {

        // Cayendo en un agujero: una animación corta y reaparece antes del agujero.
        if fallSeconds > 0 {
            fallSeconds -= seconds
            carY -= 700 * dt
            if fallSeconds <= 0 { finishFall() }
            return
        }

        // Velocidad
        let target: CGFloat = isAccelerating ? CarGameEngine.cruiseSpeed : 0
        if speed < target {
            speed = min(target, speed + CarGameEngine.acceleration * dt)
        } else if speed > target {
            speed = max(target, speed - CarGameEngine.braking * dt)
        }
        let slowed = carY < 6 && isInMud()
        carX += speed * (slowed ? CarGameEngine.mudFactor : 1) * dt

        // Salto automático (ayuda)
        if assist.autoJump, carY <= 0.5, verticalSpeed <= 0, speed > 40,
           let obstacle = nextAutoJumpTarget() {
            autoJumpedHazardID = obstacle.id
            startJump()
        }

        // Salto y gravedad
        if carY > 0 || verticalSpeed > 0 {
            verticalSpeed -= CarGameEngine.gravity * dt
            carY += verticalSpeed * dt
            if carY <= 0 {
                carY = 0
                verticalSpeed = 0
                if jumpBuffer > 0 {
                    jumpBuffer = 0
                    startJump()
                }
            }
        }
        jumpBuffer = max(0, jumpBuffer - seconds)
        if invulnerable > 0 { invulnerable -= seconds }

        // Agujeros: el carro cae si va por el suelo (la protección no cuenta aquí).
        for hazard in level.hazards where hazard.kind == .pit {
            if hazard.x - 60 > carX { break }
            if carY <= 8, carX > hazard.x + 10, carX < hazard.maxX - 10 {
                startFall(into: hazard)
                return
            }
        }

        // Choques con obstáculos sólidos
        if invulnerable <= 0 {
            let carLeft = carX - CarGameEngine.carHalfWidth
            let carRight = carX + CarGameEngine.carHalfWidth
            for hazard in level.hazards where hazard.isSolid {
                if hazard.x - 120 > carX { break }
                if hazard.maxX + 120 < carX { continue }
                let overlapsX = carRight > hazard.x + 10 && carLeft < hazard.maxX - 10
                if overlapsX && carY < max(hazard.height - 4, 1) {
                    hit()
                    break
                }
            }
        }

        collectStars()
        updateDust(dt, seconds: seconds)
        updateProgress()
    }

    // MARK: Piezas del paso

    private func startJump() {
        verticalSpeed = CarGameEngine.jumpSpeed
        Haptics.impact(.light)
    }

    private func isInMud() -> Bool {
        for hazard in level.hazards where hazard.kind == .slow {
            if hazard.x - 50 > carX { break }
            if carX >= hazard.x && carX <= hazard.maxX { return true }
        }
        return false
    }

    /// El siguiente obstáculo que hay que saltar, si ya es hora de despegar.
    /// Se despega para que lo más alto del salto quede justo encima del obstáculo.
    private func nextAutoJumpTarget() -> CarHazard? {
        let reach = speed * CarGameEngine.airTime / 2
        for hazard in level.hazards {
            if hazard.x - carX > 600 { break }
            if hazard.kind == .slow || hazard.id == autoJumpedHazardID || hazard.midX <= carX { continue }
            return hazard.midX - carX <= reach ? hazard : nil
        }
        return nil
    }

    private func hit() {
        lives -= 1
        invulnerable = CarGameEngine.invulnerableSeconds
        speed *= 0.4
        verticalSpeed = max(verticalSpeed, 420) // saltito del golpe
        Haptics.impact(.heavy)
        if lives <= 0 {
            outOfLives("¡Choque! Se quedaron sin corazones.")
        } else {
            announce("¡Choque! \(livesText)")
        }
    }

    private func startFall(into pit: CarHazard) {
        lives -= 1
        fallSeconds = 0.45
        speed = 0
        isAccelerating = false
        respawnX = max(checkpointX, pit.x - 170)
        Haptics.impact(.heavy)
        if lives > 0 { announce("Se cayeron al agujero. \(livesText)") }
    }

    private func finishFall() {
        carY = 0
        verticalSpeed = 0
        speed = 0
        if lives <= 0 {
            outOfLives("Se cayeron al agujero. Se quedaron sin corazones.")
            return
        }
        carX = respawnX
        invulnerable = 1.5
        autoJumpedHazardID = -1
    }

    private func outOfLives(_ reason: String) {
        isAccelerating = false
        phase = .outOfLives
        announce("\(reason) Pueden seguir desde el último punto de control.")
    }

    private var livesText: String {
        lives == 1 ? "Queda 1 corazón." : "Quedan \(lives) corazones."
    }

    private func collectStars() {
        for star in level.stars {
            if star.x < carX - 90 { continue }
            if star.x > carX + 90 { break }
            if collectedStars.contains(star.id) { continue }
            if abs(star.x - carX) < 50,
               star.y > carY - 16,
               star.y < carY + CarGameEngine.carHeight + 20 {
                collectedStars.insert(star.id)
                starsCollected += 1
                Haptics.selection()
            }
        }
    }

    private func updateDust(_ dt: CGFloat, seconds: Double) {
        dustTimer -= seconds
        if dustTimer <= 0, speed > 60, carY <= 0.5 {
            dustTimer = 0.07
            dust.append(CarDust(x: carX - 55, y: 8, age: 0, life: 0.55, size: CGFloat.random(in: 6...11)))
        }
        for i in dust.indices {
            dust[i].age += seconds
            dust[i].x -= 30 * dt
            dust[i].y += 25 * dt
        }
        dust.removeAll { $0.age >= $0.life }
    }

    private func updateProgress() {
        progress = min(max(carX / level.length, 0), 1)
        let percent = Int(progress * 100)
        if percent != progressPercent { progressPercent = percent }

        // Cambio de zona = punto de control
        let zone = level.zoneIndex(at: carX)
        if zone != zoneIndex {
            zoneIndex = zone
            if zone > 0 {
                checkpointX = CGFloat(zone) * CarLevel.zoneLength
                lives = CarGameEngine.maxLives
                Haptics.success()
                announce("Punto de control. Corazones completos. Zona \(zone + 1): \(level.zones[zone].name)")
            }
        }

        // Meta
        if carX >= level.length {
            carX = level.length
            speed = 0
            isAccelerating = false
            phase = .won
            Haptics.success()
            announce("¡Llegaron a la meta! Juntaron \(starsCollected) de \(level.stars.count) estrellas.")
        }
    }
}
