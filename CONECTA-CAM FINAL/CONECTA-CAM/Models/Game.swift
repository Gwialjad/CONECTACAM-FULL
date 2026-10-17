//
//  Game.swift
//  Conecta CAM
//

import SwiftUI

// MARK: - Juegos colaborativos (mínimo 2 jugadores)

enum Game: String, CaseIterable, Identifiable {
    case story, questions, teamHold
    var id: String { rawValue }

    var title: String {
        switch self {
        case .story: return "Historia en cadena"
        case .questions: return "Conociéndonos"
        case .teamHold: return "Todos a la vez"
        }
    }
    var blurb: String {
        switch self {
        case .story: return "Cada quien agrega una frase y juntos crean un cuento."
        case .questions: return "Por turnos, respondan preguntas para conocerse mejor."
        case .teamHold: return "Todos deben mantener su círculo presionado al mismo tiempo."
        }
    }
    var symbol: String {
        switch self {
        case .story: return "book.fill"
        case .questions: return "bubble.left.and.bubble.right.fill"
        case .teamHold: return "hand.tap.fill"
        }
    }
    var color: Color {
        switch self {
        case .story: return .camRed
        case .questions: return .camYellow
        case .teamHold: return .camGreen
        }
    }
    static let minPlayers = 2
    static let maxPlayers = 6
}
