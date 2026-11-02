//
//  MusicPlayer.swift
//  Conecta CAM
//

import AVFoundation

/// Música de fondo en bucle para toda la app.
/// Archivo esperado: musica_fondo.m4a (o musica_fondo.mp3) dentro del proyecto.
final class MusicPlayer {
    static let shared = MusicPlayer()

    /// Llave en UserDefaults; el interruptor del panel de Accesibilidad usa la misma.
    static let enabledKey = "conectacam.music"

    /// Volumen de 0.0 a 1.0. Está bajo a propósito para no tapar las voces ni VoiceOver.
    private let volume: Float = 0.3

    private var player: AVAudioPlayer?
    private var wantsToPlay = false   // la app está activa (en primer plano)

    private var isEnabled: Bool {
        UserDefaults.standard.object(forKey: Self.enabledKey) as? Bool ?? true
    }

    private init() {
#if os(iOS)
        // Llamadas, alarmas, Siri: al terminar la interrupción, la música continúa.
        NotificationCenter.default.addObserver(
            self, selector: #selector(handleInterruption(_:)),
            name: AVAudioSession.interruptionNotification, object: nil)
#endif
    }

    // MARK: - Control

    /// Llamar cuando la app pasa a primer plano.
    func start() {
        wantsToPlay = true
        refresh()
    }

    /// Llamar cuando la app pasa a segundo plano.
    func pause() {
        wantsToPlay = false
        player?.pause()
    }

    /// Llamar desde el interruptor "Música" del panel de Accesibilidad.
    func setEnabled(_ on: Bool) {
        UserDefaults.standard.set(on, forKey: Self.enabledKey)
        refresh()
    }

    /// Enciende o apaga según lo que corresponda ahora mismo.
    func refresh() {
        guard wantsToPlay, isEnabled else {
            player?.pause()
            return
        }
        configureSession()
        if player == nil { player = loadPlayer() }
        guard let player, !player.isPlaying else { return }
        player.volume = 0
        player.play()
        player.setVolume(volume, fadeDuration: 2) // entra suave
    }

    // MARK: - Interno

    private func loadPlayer() -> AVAudioPlayer? {
        guard let url = Bundle.main.url(forResource: "musica_fondo", withExtension: "m4a")
                ?? Bundle.main.url(forResource: "musica_fondo", withExtension: "mp3") else {
            print("MusicPlayer: no se encontró musica_fondo.m4a ni .mp3 en el proyecto")
            return nil
        }
        guard let p = try? AVAudioPlayer(contentsOf: url) else { return nil }
        p.numberOfLoops = -1   // se repite sin parar
        p.prepareToPlay()
        return p
    }

    private func configureSession() {
#if os(iOS)
        // .ambient: respeta el modo silencio, convive con otro audio y no interrumpe a VoiceOver.
        try? AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default, options: [])
        try? AVAudioSession.sharedInstance().setActive(true)
#endif
    }

#if os(iOS)
    @objc private func handleInterruption(_ note: Notification) {
        guard let raw = note.userInfo?[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: raw) else { return }
        if type == .ended { refresh() }
    }
#endif
}
