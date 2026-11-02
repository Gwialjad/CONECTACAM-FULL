//
//  Game.swift
//  Conecta CAM
//

import SwiftUI

// MARK: - Juegos colaborativos (siempre 2 jugadores)

enum Game: String, CaseIterable, Identifiable {
    case story, questions, bonus
    var id: String { rawValue }

    var title: String {
        switch self {
        case .story: return "Historia en cadena"
        case .questions: return "Conociéndonos"
        case .bonus: return "Juego especial"   // nombre provisional
        }
    }
    var blurb: String {
        switch self {
        case .story: return "Cada quien agrega una frase y juntos crean un cuento."
        case .questions: return "Por turnos, respondan preguntas para conocerse mejor."
        case .bonus: return "Un juego sorpresa que se desbloquea al cumplir todas tus metas."
        }
    }
    /// Imagen del botón en Assets.xcassets (la del juego especial es la versión bloqueada).
    var iconName: String {
        switch self {
        case .story: return "game_story"
        case .questions: return "game_questions"
        case .bonus: return "game_bonus_locked"
        }
    }
    /// Solo el juego especial necesita desbloquearse.
    var needsUnlock: Bool { self == .bonus }

    /// Todos los juegos son para exactamente 2 personas.
    static let playerCount = 2
}
